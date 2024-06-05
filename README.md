
# sukibaby's Simfile Tool :)

  

### Easily manage all your simfiles/stepcharts. Compatible with `.sm` and `.ssc` formats, and works fine with very large directories containing thousands of simfiles.

  -----

### With this program, you can:

- Choose whether to use the directory you're in, or all sub-directories as well

- Check for characters which may not work in all versions of StepMania (in other words, check for non-`IEC 8859-1` characters)

- Apply a consistent capitalization scheme to all title, subtitle, artist, or step artist fields

- Apply or remove the ITG 9ms offset

- Apply a consistent value to the banner, CD title, background, credit, or step artist fields of the simfile (for example, if you plan to have a banner called 'banner.png' in all your song directories, you can easily set that in all your simfiles at once).

- Check for .old files and remove them in bulk.


------
### How to use
 
 You can run the script directly like so:

 

`PS C:\Users\Stepper\Documents> & '.\simfile-tool.ps1' "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

 

or use the pre-built exe file in the Releases section:

 

`PS C:\Users\Stepper\Documents> .\simfile-tool.exe "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

-----

### PowerShell is required!
You can run Simfile Tool directly as a PowerShell script. 

- **Windows**: PowerShell comes pre-installed with Windows, however, on Windows 11 you need to enable running PowerShell scripts first - for this reason, the tool is also provided an an exe file in the Releases section for anyone who can't or doesn't want to enable scripts (you should also be able to run the .ps1 script in the PowerShell ISE without enabling scripts system-wide).

- **Mac**: Mac users can download PowerShell from the Microsoft website or with Homebrew.

- **Linux**: Linux users can refer to their distribution's instructions for the preferred method.

------

*Please note the code is still in early stages and is being updated frequently, so check back for updated versions.*

**Known problems:**

- Non-Unicode characters may get broken when using the auto capitalization feature.

**To-do's (check back soon!):**

- Release GUI version


*If you run into any issues, or have any suggestions, please note them on the Issues section!*


