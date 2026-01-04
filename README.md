# Unity Assignment Project Opener (For Instructors)

This tool helps instructors **quickly open many student Unity projects** without manually adding them to Unity Hub one by one.

It is designed for grading situations where:

- Students submit zipped folders in inconsistent layouts
- Unity projects may be nested several folders deep
- You need to open **many projects**, but only a few at a time (to avoid melting your computer)

------

## What This Tool Does

The workflow has **two steps**:

1. **Scan student submissions** and generate a list of valid Unity projects
2. **Open projects from that list**, limited to a set number at a time (e.g. 5)

You can edit the list between runs to skip or re-open specific students.

------

## Files Included

```
01_GenerateProjectsList.ps1   ← scans folders and finds Unity projects
02_OpenProjectsFromList.ps1   ← opens projects from a text list (5 at a time)
README.md                     ← this file
```

------

## One-Time Setup (Required)

### Enable local PowerShell scripts (safe, user-only)

1. Open **PowerShell** (normal user, not Admin)
2. Run this command:

```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

1. Press `Y` to confirm

This allows you to run scripts you create locally.

------

## Step 1 — Generate a Project List

This scans student submission folders and finds the **actual Unity project roots**, even if they are nested.

### Run this command:

```
.\01_GenerateProjectsList.ps1 -Root "D:\Marking\Assignment1" -OutFile ".\assignment1_projects.txt"
```

### What this does:

- Treats each top-level folder as a student submission
- Searches inside it for folders containing:
  - `Assets`
  - `ProjectSettings`
- Writes all found Unity projects to `assignment1_projects.txt`
- Also generates a CSV report (`projects_report.csv`) for reference

------

## Step 2 — Open Projects for Marking (5 at a Time)

Once the list exists, open projects from it:

```
.\02_OpenProjectsFromList.ps1 `
  -UnityExe "C:\Program Files\Unity\Hub\Editor\2022.3.20f1\Editor\Unity.exe" `
  -ListFile ".\assignment1_projects.txt" `
  -MaxParallel 5
```

### What this does:

- Opens **up to 5 Unity editors at once**
- As you close one, the next project opens automatically
- Uses the Unity Editor version you specify

------

## Editing the Project List (Very Important)

The list file (`assignment1_projects.txt`) is **meant to be edited**.

### Comment out projects you don’t want to open yet

Use `#` at the start of a line:

```
# Broken submission (missing ProjectSettings)
# D:\Marking\Assignment1\Student_BadUpload

D:\Marking\Assignment1\Student01\Project
D:\Marking\Assignment1\Student02\Project
```

- Lines starting with `#` are ignored
- Blank lines are ignored
- Only valid paths are opened

This lets you:

- Skip broken submissions
- Track grading progress
- Re-open only selected students later

------

## Typical Grading Workflow

1. Unzip all student submissions into a folder
2. Run the generator script once
3. Open the generated `.txt` file
4. Comment out anything you don’t want to open
5. Run the opener script
6. Grade projects as they open
7. Close Unity windows as you finish — new ones will open automatically

Repeat for Assignment 2 and 3 with different list files.

------

## Notes & Tips

- Opening too many Unity projects at once is slow — **5 is a good default**
- Projects opened this way usually appear in Unity Hub automatically
- If a project is missing `ProjectSettings`, it will be skipped (intentional)
- The scripts work even if students nest projects several folders deep

------

## Troubleshooting

### “Scripts are disabled on this system”

Run PowerShell once with:

```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

------

### A project didn’t open

- Check that the folder contains both `Assets` and `ProjectSettings`
- Make sure the path is not commented out in the list file

------

## Why This Exists

Manually opening 15–30 Unity projects per assignment is slow and error-prone.
 This tool turns that process into **two commands and a text file**, saving hours per term.