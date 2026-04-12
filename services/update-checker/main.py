#!/usr/bin/env python3
"""
Halo AI Core — Update Checker API
"Upgrades, people. Upgrades." — Marcus, The Matrix Revolutions

Checks for available package updates (lemonade-server, llama.cpp, etc.)
and provides a GUI-triggerable update endpoint.
"""

import asyncio
import os
import re
import subprocess
from datetime import datetime, timezone
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="Halo AI Update Checker",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Packages we track for updates
TRACKED_PACKAGES = [
    "lemonade-server",
    "lemonade-server-debug",
]

# Lock to prevent concurrent updates
_update_lock = asyncio.Lock()


class PackageInfo(BaseModel):
    name: str
    installed: Optional[str] = None
    available: Optional[str] = None
    has_update: bool = False


class UpdateStatus(BaseModel):
    checked_at: str
    packages: list[PackageInfo]
    updates_available: int = 0


class UpdateResult(BaseModel):
    started_at: str
    finished_at: str
    success: bool
    output: str
    packages_updated: list[str]


def get_installed_version(pkg: str) -> Optional[str]:
    """Get installed version via pacman."""
    try:
        result = subprocess.run(
            ["pacman", "-Q", pkg],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            parts = result.stdout.strip().split()
            return parts[1] if len(parts) >= 2 else None
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def get_available_version(pkg: str) -> Optional[str]:
    """Get latest available version via yay (AUR check)."""
    try:
        result = subprocess.run(
            ["yay", "-Si", pkg],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            for line in result.stdout.splitlines():
                if line.startswith("Version"):
                    match = re.search(r":\s*(.+)", line)
                    if match:
                        return match.group(1).strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


@app.get("/")
async def root():
    return {"service": "halo-ai-update-checker", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "healthy"}


@app.get("/check", response_model=UpdateStatus)
async def check_updates():
    """Check all tracked packages for available updates."""
    packages = []
    updates_count = 0

    for pkg_name in TRACKED_PACKAGES:
        installed = get_installed_version(pkg_name)
        available = get_available_version(pkg_name)
        has_update = (
            installed is not None
            and available is not None
            and installed != available
        )
        if has_update:
            updates_count += 1

        packages.append(PackageInfo(
            name=pkg_name,
            installed=installed,
            available=available,
            has_update=has_update,
        ))

    return UpdateStatus(
        checked_at=datetime.now(timezone.utc).isoformat(),
        packages=packages,
        updates_available=updates_count,
    )


@app.post("/update", response_model=UpdateResult)
async def apply_updates():
    """Apply pending updates for tracked packages via yay."""
    if _update_lock.locked():
        raise HTTPException(status_code=409, detail="Update already in progress")

    async with _update_lock:
        started = datetime.now(timezone.utc).isoformat()
        packages_to_update = []

        # Find which packages actually need updating
        for pkg_name in TRACKED_PACKAGES:
            installed = get_installed_version(pkg_name)
            available = get_available_version(pkg_name)
            if installed and available and installed != available:
                packages_to_update.append(pkg_name)

        if not packages_to_update:
            return UpdateResult(
                started_at=started,
                finished_at=datetime.now(timezone.utc).isoformat(),
                success=True,
                output="All packages already up to date.",
                packages_updated=[],
            )

        try:
            result = subprocess.run(
                ["yay", "-S", "--noconfirm", *packages_to_update],
                capture_output=True, text=True, timeout=600,
            )
            success = result.returncode == 0
            output = result.stdout + ("\n" + result.stderr if result.stderr else "")
        except subprocess.TimeoutExpired:
            success = False
            output = "Update timed out after 10 minutes"
        except Exception as e:
            success = False
            output = str(e)

        return UpdateResult(
            started_at=started,
            finished_at=datetime.now(timezone.utc).isoformat(),
            success=success,
            output=output[-2000:],  # cap output size
            packages_updated=packages_to_update if success else [],
        )


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("UPDATE_CHECKER_PORT", "5080"))
    print(f"Update Checker starting on :{port}")
    uvicorn.run(app, host="127.0.0.1", port=port)
