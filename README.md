# Sanitize-PDF.bat

Sanitize or Flatten PDF documents to remove "active content" so they pass through corporate firewalls better.

If you create multi-page PDFs with many pictures and graphics (such as a portfolio) and email them out to companies with strict firewalls (such as an HR department) you may have had those emails bounce back with an error message such as **"error: messages with active content/attachments (e.g. Office macros) will not be transmitted."**

PDFs can gain these features for any number of reasons, sometimes it's just the tools we use to create them. For example, it could be something as simple as using the "save as PDF" feature from Word docs, then using a free tools such as [PDF Split-And-Merge][2] to combine several of them into a single PDF document.

No matter how they gain them, there is a surprising lack of tools available to simply delete any "active content" a PDF may contain. It seems like the only easy solution requires either using an older (unavailable) version of Adobe Reader or paying for a full copy of Adobe Acrobat:

- [forums.adobe.com -
How do I remove active content from a pdf file](https://forums.adobe.com/thread/1644285)
- [Step 4:  Preparing a PDF For Posting - HHS.gov](https://www.hhs.gov/web/section-508/making-files-accessible/create-accessible-pdfs/step-4/index.html)

Another (free) option is Ghostscript, "an interpreter for the PostScript language and for PDF". [PostScript](https://www.adobe.com/products/postscript.html) [2](https://en.wikipedia.org/wiki/PostScript) is old enough that it does not support embedded Flash or JavaScript exploits that may be present in modern PDFs. This question from **security.stackexchange.com** lays out the method employed here: [**Effectiveness of flattening a PDF to remove malware**][1].

# Index:

- [Sanitize-PDF.bat](#sanitize-pdfbat)
- [Index:](#index)
- [What it is](#what-it-is)
- [How to Use](#how-to-use)
	- [Helper functions](#helper-functions)
	- [Choosing a method](#choosing-a-method)
	- [How to modify/customize the script:](#how-to-modifycustomize-the-script)
- [How to Install](#how-to-install)
	- [#1. To automatically install everything](#1-to-automatically-install-everything)
		- [How to choose which installer method:](#how-to-choose-which-installer-method)
	- [#2. If you already have Chocolatey installed](#2-if-you-already-have-chocolatey-installed)
			- [Post-install instructions:](#post-install-instructions)
	- [#3. To manually install GhostScript yourself (required dependency)](#3-to-manually-install-ghostscript-yourself-required-dependency)
	- [#4. If you already have GhostScript installed](#4-if-you-already-have-ghostscript-installed)
		- [Handling download errors](#handling-download-errors)
- [Thanks to:](#thanks-to)
- [How to Contribute:](#how-to-contribute)
	- [More info about GhostScript options:](#more-info-about-ghostscript-options)
		- [Notes if contributing Pull Requests:](#notes-if-contributing-pull-requests)
- [Disclaimer:](#disclaimer)

# What it is

**Sanitize-PDF.bat** is a Batch file (Windows only) which runs as a wrapper for [GhostScript](https://www.ghostscript.com/), a command-line PDF/PostScript "printer" (converter). The original purpose of this script was fixing recently coverted-to-PDF Resume/CV documents, quickly, by **dragging-and-dropping** a PDF file onto a .bat script. Then GhostScript is called with various command-line options applied, currently using 3 different methods to "clean" the PDFs of Active Content.

# How to Use

Once installed, you simply drag-and-drop a PDF onto **Sanitize-PDF.bat** and it will call [GhostScript](https://www.ghostscript.com/) with 3 different sets of command line options, which will produce 3 different files. Sanitize-PDF.bat does not modify or delete the original source document dropped on it.

![Example video of Sanitize-PDF.bat in use.][Sanitize PDF demonstration]

There are 3 "methods" used in the Ghostscript invocation phase:

1. Convert **PDF-to-PDF** using the ghostscript device `pdfwrite`. ~~Output usually has a smaller file size, suggesting this method does remove things.~~ As you can see in the above example video, this is not always true. Sometimes the output file will be larger. *By default,* this produces **flattened.pdf**
2. Convert **PDF-to-PostScript-to-PDF**, using devices `ps2write` and `pdfwrite`. Although this is the recommended method from the [security.SE question][1] to remove malware since it fully converts a PDF file to a PostScript 2 file (which inherently does not support Active Content) and writes it to disk, then converts that PS document to PDF again, in my testing ~~the final PDF ends up *larger* than the original.~~* This may be understandable since the intermediary PostScript document ends up around 20-30 MB in size generated from a 2-3 MB PDF document. * = As you can see in the above example video, this is not always true either, sometimes the output file is smaller. *By default,* this produces a **flattened.ps** PostScript placeholder file, then uses that to generate **flattened_postscript.pdf**
    > This method also takes a significantly longer time to execute. In the above example video, the execution time of Method #2 is edited for demostration purposes. To disable Method #2 execution, edit the parameter in **Sanitize-PDF.bat** to `SET "_METHOD_2=OFF"`. To re-enable, `SET "_METHOD_2=ON"`
3. Convert **PDF-to-PDF and downsize all images**, using the `pdfwrite` device. This method is also recommended by the [Security SE question][1] to remove any image-based malware. So in theory, it should always produce a smaller output file. However if the input PDF document contains absolutely no image data, that may not be true either. *By default,* this produces **flattened_lowres.pdf**

As you can see from the above examples, the resulting file size of each method can vary wildly, depending on the input PDF. The output files can then each be inspected, and the one that best fits the requirements can be copied and renamed for use.

> As of [**v1.2.1** or greater][4] file size comparison summary data will be printed at the end of script execution, for easy inspection. 

After the script has ended, if you "Press ANY key..." it will delete the placeholder PostScript file. Alternatively, you can close the script window at this point and the postscript.ps file will remain for inspection.

## Helper functions

If you frequently update the source PDF and want to rename the output to the same file name repeatedly, the script **AutoRenamePDF.bat** will do that automatically. Rename the script to the file name you want. For example, **"My New PDF Name.bat"**:

![Example video of AutoRenamePDF.bat in use.][Auto Rename PDF demonstration]

will convert any .pdf file dropped on it to **"My New PDF Name.pdf"**

## Choosing a method

There's conflicting motivations here, which may inspire different preferences for each of these methods. While both perspectives want to remove "Active Content" from the PDF, my guess is that you either want to:

- **Remove malware** from unfamiliar PDF documents as completely as possible.
- **Reduce file size** and shed any extra "Active Content" a PDF file you produced may contain, so it's more likely to successfully pass through firewalls when you email it later.

Both want to remove Active Content, but either you yourself produced the file, and *know* for the most part, it's safe. Or, you picked up a PDF file from the internet or email, and want to make sure it's safe before opening.

*Sanitize-PDF.bat* was written mainly in the spirit of the **second** motivation. We produced the file, we know it's not intentionally malicious. We just want email server firewalls more accepting of them. For that scenario, we also generally want to pick whichever output file is the smallest.

For the first motivation however, where we care more about **removing malware** than PDF file size, it is still possible to achieve this if you run the *Sanitize-PDF.bat* script twice. 

1. After the first run, Method #2 will produce a **flattened_postscript.pdf** file that has been completely converted to PostScript 2 (which does not support Active Content) and back to PDF again. 
2. Then, if you drop **flattened_postscript.pdf** back into **Sanitize-PDF.bat** (remember to disable Method #2 execution option first for faster run time), after it has completed, Method #3 will have produced **flattened_lowres.pdf** which then has also down-sized picture resolutions, to protect against image-based malware.

> [**2019-01-24** World's favourite open-source PDF interpreter needs patching (again)
Still afraid of no ghost? You didn't read the script - TheRegister.co.uk](https://www.theregister.co.uk/2019/01/24/pdf_ghostscript_vulnerability/)
> **FYI:** This is not a 100% perfect method for removing malware. A vulnerability was found present in all GhostScript versions up to '**9.26**'. If you do not trust the source of the PDF, do not open it. This software is provided "as-is" with no warranty. See [Disclaimer](#disclaimer) at the bottom of this README and the [LICENSE](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/LICENSE) for this repo.
> As of this writing, [GhostScript 9.50](https://www.ghostscript.com/Ghostscript_9.50.html) is available.

---

## How to modify/customize the script:

Either drag-and-drop a pdf file onto **Sanitize-PDF.bat**, or edit the `_INPUT_PDF` variable in the `:Parameters` section at the very top of the script, then run it.

To edit Sanitize-PDF.bat, right-click the file and select **Edit**. [Notepad++](https://chocolatey.org/packages/notepadplusplus) is a fantastic recommended editor for **.bat** files and many others, better than `notepad.exe`.

All input variables are set at the top of Sanitize-PDF.bat in the `:Parameters` block. You can even change the names of the 3 final output PDFs, and the PostScript intermediary file, if you like. The following screenshot was taken in the [Visual Studio Code](https://chocolatey.org/packages/vscode) editor.

![Example image of Parameters block in Sanitize PDF][Sanitize PDF Parameters block image]

To change how images are downsized (only used in the 3rd method as described above), the `_DPI` variable can be changed to whatever you like. I have several lines setting this var to different values, so you only have to comment out `::` the last lines you don't wish to use; it doesn't matter if you comment out lines above the `_DPI` values you wish to use. By default this script has:

```CMD
SET "_DPI=63"
SET "_DPI=120"
SET "_DPI=150"
SET "_DPI=170"
SET "_DPI=200"
::SET "_DPI=250"
::SET "_DPI=300"
```

So, DPI will be set to 200 by default. If you wish to use 250, simply uncomment that line. To use 150 DPI instead, simply comment out all the `SET "_DPI="` lines after it.

---

# How to Install

To get started, you need 2 pieces of softare. 

1. [**GhostScript**](https://chocolatey.org/packages/Ghostscript), a command-line tool for converting PDF and PostScript files, that needs to be installed on your local system.
2. [**Sanitize-PDF.bat**](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/Sanitize-PDF.bat), a Batch script file which you can place anywhere on your local system, on your Desktop, in your My Documents folder, etc. After **GhostScript** is installed, **Sanitize-PDF.bat** can be used to automatically call it with the necessary command-line parameters to generate several (3, at this moment) versions of that PDF document, converted with different methods to remove Active Content.

Choose one of the following 4 install methods (rated by ease-of-use):

- [#1. To automatically install everything](#1-to-automatically-install-everything)
	- [How to choose which installer method:](#how-to-choose-which-installer-method)
- [#2. If you already have Chocolatey installed](#2-if-you-already-have-chocolatey-installed)
			- [Post-install instructions:](#post-install-instructions)
- [#3. To manually install GhostScript yourself (required dependency)](#3-to-manually-install-ghostscript-yourself-required-dependency)
- [#4. If you already have GhostScript installed](#4-if-you-already-have-ghostscript-installed)
	- [Handling download errors](#handling-download-errors)

## #1. To automatically install everything

Head over to the [**Releases**][4] page to find the most recent stable versions, find the [latest one](https://github.com/Kerbalnut/Sanitize-PDF/releases/latest), and download the **Source code (zip)**.

Once finished downloading, un-zip the file, and in it you will find an [install](https://github.com/Kerbalnut/Sanitize-PDF/tree/master/install) folder with:

- `BoxstarterInstall-Ghostscript.bat`
- `Install-Chocolatey.bat`

Both of these are automation scripts that will will enable Sanitize-PDF.bat dependency installation of GhostScript, required for the script to function. Pick either one (both will require Administrator permissions), and run one of them by **double-clicking** on it.

A reboot may be necessary.

Afterwards, **Sanitize-PDF.bat** is ready to run.

### How to choose which installer method:

How to choose between `Install-Chocolatey.bat` and `BoxstarterInstall-Ghostscript.bat`? Both rely on [**Chocolatey**](https://chocolatey.org) to automatically install [GhostScript](https://www.ghostscript.com).

- Use [`BoxstarterInstall-Ghostscript.bat`](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/install/BoxstarterInstall-Ghostscript.bat) for a 1-shot, all-in-one install method with no unnecessary extras. - ([Source](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/BoxstarterInstall-template.bat))
- Use [`Install-Chocolatey.bat`](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/install/Install-Chocolatey.bat) if you wish to experiment with  [Chocolatey](https://chocolatey.org/packages) to manage other Windows software installs and automatic updates e.g. `\> choco upgrade Ghostscript` - ([Source](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Tools/Install-Chocolatey.bat))

*The original source for both of these scripts is a* [*separate GitHub repo.*](https://github.com/Kerbalnut/Batch-Tools-SysAdmin)

> **Chocolatey** is a package manager used to automate software installs, like apt-get for Windows. It is essentially a wrapper for the [NuGet package system](https://www.nuget.org/), which *packages* software by storing additional metadata about how to use it in a standardized format. You can install Chocolatey by following the [official instructions on Chocolatey.org](https://chocolatey.org/install), or by running [`Install-Chocolatey.bat`](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/install/Install-Chocolatey.bat), which is essentially a wrapper for the PowerShell 1-liner from the official documentation (and also automatically requests Administrator permissions when you **double-click** it).
> 
> Once Chocolately is installed, **Sanitize-PDF.bat** will detect if GhostScript has not been installed yet, and automatically call Chocolately to handle the install (with `choco install ghostscript -y`) when starting up. Double-click **Sanitize-PDF.bat** and the dependency checks and chocolatey automatic install will run, until the *"no input PDF found"* error is reached.
> 
> [**Boxstarter**](https://boxstarter.org/) is essentially a wrapper for Chocolatey. It allows packages from the [Chocolatey public repository](https://chocolatey.org/packages) to be installed without requiring the user to install Chocolatey first. It also has a few other features, such as additional functions useful for setting up a computer after a fresh Windows install like changing certain Windows OS options & prefences; or such as the ability to **call a runtime executable through IE (using native Windows tools) to run a Boxstarter script** without having Boxstarter installed yet, either. This is the feature the script [`BoxstarterInstall-Ghostscript.bat`](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/install/BoxstarterInstall-Ghostscript.bat) employs, which is essentially a wrapper for IE & Boxstarter. It builds the URL for the Boxstarter runtime executable script to install the GhostScript package (from Chocolatey), then finds IE, and calls it with that URL.

## #2. If you already have Chocolatey installed

Install GhostScript:  (Run As Administrator)

- [Chocolatey package](https://chocolatey.org/packages/Ghostscript) install: `\> choco install ghostscript -y` 

A reboot may be necessary.

#### Post-install instructions:

~~It seems like chocolatey does not always successfully [auto-shim](https://github.com/chocolatey/choco/wiki/FeaturesShim) the ghostscript executables after install. Which means you will have to shim the executables yourself to successfully call them from the batch file.~~

*(Note: [shimgen.exe](https://chocolatey.org/docs/FeaturesShim) is a free tool included with Chocolatey)*

~~Run from command prompt or PowerShell:~~

*Assuming a 64-bit OS:* `shimgen --output=gswin64c --path="$env:ProgramFiles\gs\gs9.23\bin\gswin64c.exe" --debug`

~~With *Ghostscript* installed, and gswin64c.exe either *shimmed* or added to the *PATH variable* as described above, Sanitize-PDF.bat is ready to use.~~

> [**v1.1.1** or greater][4] of **Sanitize-PDF.bat** will automatically install & shim Ghostscript (`gswin64c.exe`) if you have [chocolatey](https://chocolatey.org/install) installed.

Then, follow the remaining instructions in **#4. If you already have GhostScript installed**

## #3. To manually install GhostScript yourself (required dependency)

Head over to the [GhostScript installer page](https://www.ghostscript.com/download/gsdnld.html), download the appropriate version for your system, and run the installer.

A reboot may be necessary.

> [**v1.1.1** or greater][4] of **Sanitize-PDF.bat** will automatically add Ghostscript (`gswin64c.exe`) to your PATH environment variable, if it is found.

Then, follow the remaining instructions in **#4. If you already have GhostScript installed**

## #4. If you already have GhostScript installed

Head to the [**Releases**][4] page to find the latest stable version of **Sanitize-PDF.bat** and download it. If you run into trouble with firewalls/anti-virus/anti-malware warnings while downloading the .bat file, try the **Source code (zip)** download instead.

### Handling download errors

If you still get firewall/anti-virus/anti-malware/proxy services blocking even your **Source code (zip)** download attempts, you can always easily create the batch file script yourself:

1. Open [Sanitize-PDF.bat](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/Sanitize-PDF.bat) on GitHub and click the ["Raw" link](https://raw.githubusercontent.com/Kerbalnut/Sanitize-PDF/master/Sanitize-PDF.bat)
2. Press **Ctrl+A** to Select All, then **Ctrl+C** to Copy
1. Open `notepad.exe`
2. Paste the contents into `notepad` with **Ctrl+V**
5. Save as **"Sanitize-PDF.bat"**
	- If you receive a warning that changing file extensions will corrupt the document, click **Yes** to proceed with the change. The file extension **must** be changed to .bat for the script to work.

# Thanks to:

- Go to [Secruity.SE][1] and upvote that question for having such an awesome, accurate, functional answer in it. I basically copied and pasted their work verbatim.
- [PDFSAM Basic][2] is a free PDF Split-And-Merge tool, functionality normally only found in paid-for software. I use it all the time and never paid them a dime, so the best I can do for now is promote them for being awesome. Use it, share them on social media, and don't forget you can install [via Chocolatey](https://chocolatey.org/packages/pdfsam): `choco install pdfsam -y`
- [Chocolatey](https://chocolatey.org) is an awesome tool for automating installing, uninstalling, updating, and managing software versions. You can install packages from their public repository, from a local source, or set up your own repository for internal use. They offer Pro and Business [editions](https://chocolatey.org/pricing) with virus scanning features and more, but the main functionality is always free.
- And of course, the star of the show: [Ghostscript](https://ghostscript.com/)! Promote them on social media, help contribute if you know how, or help them bug test. A shout-out to all the folks who helped with this project for being awesome.

# How to Contribute:

1. Please send me any [bug reports][3] and [feature requests][3] through GitHub, just use the [Issue tracker][3] with the **bug**, **enhancement**, or **question** [labels](https://github.com/Kerbalnut/Sanitize-PDF/labels). No promises on delivery dates though!
2. To contribute directly, [fork this repository](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-forks) on GitHub, then [clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository-from-github) to your local machine. I recommend installing both [GitHub Desktop](https://desktop.github.com/) and [TortoiseGit](https://tortoisegit.org/) to help you interact with git repos, or [VS Code](https://code.visualstudio.com/) for an all-in-one solution with it being an IDE (code editor), split-screen markdown editor, and git-integrated. (Or all three, which can all be installed via [chocolatey](https://chocolatey.org/install): `choco install github-desktop tortoisegit vscode -y`) In your forked repo, you can create/publish/merge branches, pull updates from this parent repo, and when ready to share your changes, submit a [pull request from your fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).

## More info about GhostScript options:

- [More info on Ghostscript devices](https://ghostscript.com/doc/current/Devices.htm)
- [More info on PDF switches](https://www.ghostscript.com/doc/9.23/Use.htm#PDF)
- [LOTS more info on PDF switches](https://www.ghostscript.com/doc/9.23/VectorDevices.htm#PDFWRITE) (thank you again to @symcbean from [stackexchange][1] for distilling this down into something workable!)

### Notes if contributing Pull Requests:

There are essentially 3 parts to this script even though it's not formatted to look that way, but referring to it this way will make it easier to talk about. The first part captures variables (and deletes waste) for use in the rest of the script. The second part is where ghostscript is invoked (gswin64c.exe) to execute several methods of removing "active content" as found in the [Security SE question][1]. The third and last part compares file sizes as a quick and simple method to show if the PDFs successfully lost any information from the conversion process (which is exactly what we want, we're trying to remove "active content" which we didn't intend to include, yet may be present in our PDFs anyway).

# Disclaimer:

This script is not intended to remove all/any malware from any PDF or any other document, and makes no such promises, and offers no warranty. Use at your own risk. 

See the [LICENSE](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/LICENSE) attached to this repository for full legal information. I've chosen the MIT license so this repo may be cloned, modified, and distributed within any organization free of charge, the only requirement being preservation of copyright and license notices. See [choosealicense.com/licenses/mit/](https://choosealicense.com/licenses/mit/) for a quick overview analysis of this license. 

However if you do make any signficant improvements that you don't mind sharing, you're always encouraged to submit a [Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) through GitHub to help contribute to this project.

GhostScript is [distributed](https://www.ghostscript.com/download/gsdnld.html) with the [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html) ([**GNU Affero General Public License v3.0**](https://choosealicense.com/licenses/agpl-3.0/)) [license](https://www.ghostscript.com/license.html), a [GPL-compatible](https://www.gnu.org/licenses/gpl-faq.html#WhatDoesCompatMean) license. As of right now, I do not plan to re-distribute GhostScript (Tracked in [**Issue #7**](https://github.com/Kerbalnut/Sanitize-PDF/issues/7)), but I'm open to comments. If it would still be easier for people to use this automation script with *ghostscript* included with it, even after I release the ~~coming install-automation-helper scripts ([#3](https://github.com/Kerbalnut/Sanitize-PDF/issues/3))~~, and ~~define manual install methods better in the README refactor ([#4](https://github.com/Kerbalnut/Sanitize-PDF/issues/4))~~, then I suppose I'll think about it.

> [Added in **v1.3.0**](https://github.com/Kerbalnut/Sanitize-PDF/releases)

[1]: https://security.stackexchange.com/questions/103323/effectiveness-of-flattening-a-pdf-to-remove-malware
[2]: https://pdfsam.org/download-pdfsam-basic/
[3]: https://github.com/Kerbalnut/Sanitize-PDF/issues
[4]: https://github.com/Kerbalnut/Sanitize-PDF/releases

<!-- [Sanitize PDF demonstration]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "v1.2.1 Some parts of this example video have been sped up from real-time execution." -->

[Sanitize PDF demonstration]: /documentation/media/SanitizePDF_ExecutionDemo.gif "v1.2.1 Some parts of this example video have been sped up from real-time execution."

[Auto Rename PDF demonstration]: /documentation/media/AutoRenameExample.gif "Rename this script to whatever you want, and it will create a renamed copy of whatever file you drag and drop onto it."

[Sanitize PDF Parameters block image]: /documentation/media/SanitizePDF_ParametersBlock_VSCode.PNG "The :Parameters block can be found directly at the top of the Sanitize-PDF.bat script. This is where all variables affecting the script's execution can be modified."



