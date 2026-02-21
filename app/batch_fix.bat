@echo off
setlocal enabledelayedexpansion

REM Milestone/Task tests bulk replacement script
for /R test\application\use_cases\milestone %%F in (*.dart) do (
  powershell -Command "(Get-Content '%%F') -replace 'id: GoalId\(', 'itemId: ItemId(' | Set-Content '%%F'"
  powershell -Command "(Get-Content '%%F') -replace 'id: MilestoneId\(', 'itemId: ItemId(' | Set-Content '%%F'"
  powershell -Command "(Get-Content '%%F') -replace 'id: TaskId\(', 'itemId: ItemId(' | Set-Content '%%F'"
  powershell -Command "(Get-Content '%%F') -replace 'title: GoalTitle\(', 'title: ItemTitle(' | Set-Content '%%F'"
  powershell -Command "(Get-Content '%%F') -replace 'title: MilestoneTitle\(', 'title: ItemTitle(' | Set-Content '%%F'"
  powershell -Command "(Get-Content '%%F') -replace 'title: TaskTitle\(', 'title: ItemTitle(' | Set-Content '%%F'"
)
