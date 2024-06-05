
# Sukibaby's Simfile Tool :)

### Easily manage all your simfiles/stepcharts. Compatible with `.sm` and `.ssc` formats, and works fine with very large directories containing thousands of simfiles.



https://github.com/sukibaby/simfile-tool/assets/163092272/15c4e040-ece5-4354-abdf-32ea1acff859


  -----

### With this program, you can:

- Choose whether to use the directory you're in, or all sub-directories as well

- Check for characters which may not work in all versions of StepMania

- Apply a consistent capitalization scheme to all title, subtitle, artist, or step artist fields

- Apply or remove the ITG 9ms offset

- Apply a consistent value to the banner, CD title, background, credit, or step artist fields of the simfile (for example, if you plan to have a banner called 'banner.png' in all your song directories, you can easily set that in all your simfiles at once).

- Check for .old files and remove them in bulk.

- Check for characters which may get removed or replaced during file transfer, and rename files/update values in simfiles accordingly

-----
### How to use
### PowerShell is required!
You can run Simfile Tool directly as a PowerShell script. 

- **Windows**: PowerShell comes pre-installed with Windows
  - On Windows 11, you need to enable execution of PowerShell scripts to run the .ps1 file. If you don't want to, or can't, an exe file is provided in the Releases section. The exe does not get updated as frequently as the script.

- **Mac**: Mac users can download PowerShell from the Microsoft website or with Homebrew.

- **Linux**: Linux users can refer to their distribution's instructions for the preferred method.
 
 You can run the script directly like so:

 

`PS C:\Users\Stepper\Documents> & '.\simfile-tool.ps1' "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

 

or use the pre-built exe file in the Releases section:

 

`PS C:\Users\Stepper\Documents> .\simfile-tool.exe "C:\Users\Stepper\Documents\StepMania 5\Songs\In The Groove"`

------

*This is an active project, so check back for updated versions.*

**Known problems:**

- Non-Unicode characters may get broken when using the auto capitalization feature.
- Directories containing the `[` or `]` characters may result in errors (a warning will be displayed if these are detected when the program is run)

**To-do's (check back soon!):**

- Release GUI version


*If you run into any issues, or have any suggestions, please note them on the Issues section!*


