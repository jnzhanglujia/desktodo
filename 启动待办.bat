@echo off
chcp 65001 >nul
title 桌面待办
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0TodoWidget.ps1"
