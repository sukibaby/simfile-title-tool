
# sukibaby's Simfile Tool :)

  

### Easily manage all your simfiles/stepcharts. Compatible with `.sm` and `.ssc` formats, and works fine with very large directories containing thousands of simfiles.

  -----

### With this program, you can:

- Use the directory you're in, or all sub-directories too

- Check for characters which may not work in all versions of StepMania (in other words, check for non-`IEC 8859-1` characters)

- Apply a consistent capitalization scheme to all title, subtitle, or artist fields

- Apply or remove the ITG 9ms offset

- Apply a value to the banner, CD title, background, step artist, or credit fields of the simfile

- Check for .old files, and remove them in bulk.


------
### How to use
 
 You can run the script directly like so:

 

`PS C:\Users\Stepper\Documents> & '.\simfile-tool.ps1' "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

 

or use the pre-built exe file in the Releases section:

 

`PS C:\Users\Stepper\Documents> .\simfile-tool.exe "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

-----

### PowerShell is required!
You can run Simfile Tool as a PowerShell script, or download a pre-compiled Windows exe in the "Releases" section.

- PowerShell comes pre-installed with Windows.

- Mac users can download PowerShell from the Microsoft website or with Homebrew.

- Linux users can refer to their distribution's instructions for the preferred method.

------

*Please note the code is still in early stages and is being updated frequently, so check back for updated versions.*

**Known problems:**

- Non-Unicode characters may get broken when using the auto capitalization feature.

**To-do's (check back soon!):**

- Enable capitalization features for step artist field
- Release GUI version


*If you run into any issues, or have any suggestions, please note them on the Issues section!*


