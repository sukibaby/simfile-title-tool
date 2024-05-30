# simfile-tool
Easily manage all your simfiles/stepcharts. Compatible with `.sm` and `.ssc` formats, and works fine with very large directories containing thousands of simfiles. You can run it as a PowerShell script, or download a pre-compiled exe in the "Releases" section.

With this program, you can:
- Use the directory you're in, or all subdirectories too (change your entire Songs folder at once, if you want)
- Check for characters which may not work in all versions of StepMania
- Apply a consistent capitalization scheme to all title, subtitle, or artist fields
- Apply or remove the ITG 9ms offset
- Apply a value to the banner, CD title, background, step artist, or credit fields of the simfile
- If you want to update a simfile to use underscores instead of spaces in the file name, update the information in the simfile accordingly.

You can run the script directly like so:

`PS C:\Users\Stepper\Documents> & '.\simfile-tool.ps1' "C:\Users\Stepper\SMTestDir"`

or use the pre-built exe file in the Releases section:

`C:\Users\Stepper\Documents> .\simfile-tool.exe "C:\Users\Lil wow\SMTestDir"`

PowerShell, which is included with Windows, is required to run the script directly. If you don't have that, please try the pre-compiled exe.
