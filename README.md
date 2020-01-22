# Sanitize-PDF.bat
Sanitize or Flatten PDF documents to remove "active content" so they pass through corporate firewalls better.

If you create multi-page PDFs with many pictures and graphics (such as a portfolio) and email them out to companies with strict firewalls (such as an HR department) you may have had those emails bounce back with an error message such as **"error: messages with active content/attachments (e.g. Office macros) will not be transmitted."**

PDFs can gain these features for any number of reasons, sometimes it's just the tools we use to create them. For example, it could be something as simple as using the "save as PDF" feature from Word docs, then using a free tools such as [PDF Split-And-Merge][2] to combine several of them into a single PDF document.

No matter how they gain them, there is a surprising lack of tools available to simply delete any "active content" a PDF may contain. It seems like the only easy solution requires either using an older (unavailable) version of Adobe Reader or paying for a full copy of Adobe Acrobat:

- [forums.adobe.com - 
How do I remove active content from a pdf file](https://forums.adobe.com/thread/1644285)
- [Step 4:  Preparing a PDF For Posting - HHS.gov](https://www.hhs.gov/web/section-508/making-files-accessible/create-accessible-pdfs/step-4/index.html)

Another (free) option is Ghostscript, "an interpreter for the PostScript language and for PDF". [PostScript](https://www.adobe.com/products/postscript.html) [2](https://en.wikipedia.org/wiki/PostScript) is old enough that it does not support embedded Flash or JavaScript exploits that may be present in modern PDFs. This question from security.stackexchange.com lays out the method employed here: [**Effectiveness of flattening a PDF to remove malware**][1].

## Dependencies:

 1. **Ghostscript 9.23** - [Chocolatey package](https://chocolatey.org/packages/Ghostscript) install: `choco install ghostscript -y`

Chocolatey is a package manager, used to automate software install, like apt-get for Windows. [Install Chocolatey](https://chocolatey.org/install).

#### Post-install instructions:

It seems like chocolatey does not successfully [auto-shim](https://github.com/chocolatey/choco/wiki/FeaturesShim) the ghostscript executables after install. Which means you will have to shim the executables yourself to successfully call them from the batch file. 

*(Note: [shimgen.exe](https://chocolatey.org/docs/FeaturesShim) is a free tool included with Chocolatey)*

Run from command prompt or PowerShell:

*Assuming a 64-bit OS:* `shimgen --output=gswin64c --path="$env:ProgramFiles\gs\gs9.23\bin\gswin64c.exe" --debug`

> [**v1.1.1** or greater](https://github.com/Kerbalnut/Sanitize-PDF/releases) of **Sanitize-PDF.bat** will automatically install & shim Ghostscript if you have [chocolatey](https://chocolatey.org/install) installed.

## How-to-Use:

With *Ghostscript* installed, and gswin64c.exe either *shimmed* or added to the *PATH variable* as described above, Sanitize-PDF.bat is ready to use. 

Either drag-and-drop a pdf file onto **Sanitize-PDF.bat** or, edit the `_INPUT_PDF` variable in the :Parameters section at the very top of the script and run it. That's it!

Once finished, the Sanitize-PDF.bat will have generated 3 new PDF documents in the same folder as the input PDF. These three new documents are the result of the different methods employed to sanitize or flatten the original, as described below.

Sanitize-PDF.bat does not change or delete the original source document dropped on it. 

### How-it-works:

There are essentially 3 parts to this script even though it's not formatted to look that way, but referring to it this way will make it easier to talk about. The first part captures variables (and deletes waste) for use in the rest of the script. The second part is where ghostscript is invoked (gswin64c.exe) to execute several methods of removing "active content" as found in the [Security SE question][1]. The third and last part compares file sizes as a quick and simple method to show if the PDFs successfully lost any information from the conversion process (which is exactly what we want, we're trying to remove "active content" which we didn't intend to include, yet may be present in our PDFs anyway).

There are 3 "methods" used in the Ghostscript invocation phase:

1. Convert PDF-to-PDF using the ghostscript engine (assuming it works as a PostScript engine), using device `pdfwrite`. Output usually has a smaller file size, suggesting this method does remove things. 
2. Convert PDF-to-PostScript-to-PDF, using devices `ps2write` and `pdfwrite`. Although this seems like a saner method since it fully converts a PDF to a PostScript 2 document and writes it to disk, then takes that PS document as input and converts it to PDF again, in my testing the final PDF ends up *larger* than the original. This may be understandable since the intermediary PostScript document ends up around 20-30 MB in size generated from a 2-3 MB PDF document, but still not what we're looking for. 
3. Convert PDF-to-PDF and downsize all images, using `pdfwrite` device. This is the method recommended by the [Security SE question][1] and surprise surprise, it's the one that's been the most successful for me. 

[More info on Ghostscript devices](https://ghostscript.com/doc/current/Devices.htm)

[More info on PDF switches](https://www.ghostscript.com/doc/9.23/Use.htm#PDF)

[LOTS more info on PDF switches](https://www.ghostscript.com/doc/9.23/VectorDevices.htm#PDFWRITE) (thank you again to @symcbean from [stackexchange][1] for distilling this down into something workable!)

After the script has ended, if you "Press ANY key..." it will delete the placeholder PostScript file. Alternatively, you can close the script window at this point and the postscript.ps file will remain for inspection.

### How-to-modify:

All input variables are set at the top of Sanitize-PDF.bat. You can change the names of the 3 final output PDFs, and the PostScript intermediary file, if you like.

To change how images are downsized (only used in the 3rd method as described above), the `_DPI` variable can be changed to whatever you like. I have several lines setting this var to different values, so you only have to comment out `::` the last lines you don't wish to use; it doesn't matter if you comment out lines above the `_DPI` values you wish to use. By default this script has:

```
SET "_DPI=63"
SET "_DPI=120"
SET "_DPI=150"
SET "_DPI=200"
::SET "_DPI=300"
```

So DPI will be set to 200 by default. If you wish to use 300, simply uncomment that line. To use 150 DPI instead, simply comment out the 200 line.


## (Un)planned features:

This script is intended to be a quick-n-dirty method to clean single PDFs before emailing them. The following is a list of some features that *could* be added later, but as it is now, this script is considered feature-complete ([v1.0](https://github.com/Kerbalnut/Sanitize-PDF/releases)). **Note:** Officially, new features and bugfixes will be handled using [GitHub's Issue tracker](https://github.com/Kerbalnut/Sanitize-PDF/issues).

 - ~~Auto-install Ghostscript 9.23 and auto-shim `gswin64c.exe`. I already have Get-Chocolatey.bat scripts I could whip together with something that calls shimgen.exe~~ Completed as of **[v1.1.0](https://github.com/Kerbalnut/Sanitize-PDF/releases/tag/v1.1.0)**
 - ~~Auto-detect 32-bit installs and adjust itself properly. I could either make copies of all 64-bit based scripts, or use a Find-and-replace function to modify the same scripts automatically.~~ Tracked in GitHub [Issue #2](https://github.com/Kerbalnut/Sanitize-PDF/issues/2)
 - ~~Location independence - Currently, the Sanitize-PDF.bat is intended to reside in the same folder as the source PDFs, to make it easy to drag-and-drop and have the outputs ready in the same folder. To make it capable of accepting documents from other folders brings up the question of where to save the output PDFs: where the source document is located, or where the script itself is located? Possible, but it's complexity I'm not ready to add yet.~~ Completed as of **[v1.2.0](https://github.com/Kerbalnut/Sanitize-PDF/releases/tag/v1.2.0)**
 - Add a [`Install-Chocolatey.bat`](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Tools/Get-Chocolatey.bat) or [`BoxstarterInstall-Ghostscript.bat`](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/BoxstarterInstall-template.bat) helper script/function to this repository to enable automatic dependency (Ghostscript) installation. I already use these scripts tracked elsewhere in the [Batch-Tools-Sysadmin](https://github.com/Kerbalnut/Batch-Tools-SysAdmin) repository, which is quickly becoming convoluted and messy, and needs to be split into several smaller, inter-dependent child repositories. So the question is how to track repo dependencies or shared resources between Github projects, sub-repos, child-trees... A quicker solution may be to copy and paste one of those scripts here for now while I get the rest of that sorted. **Tracked in GitHub** [**Issue #3**](https://github.com/Kerbalnut/Sanitize-PDF/issues/3)
 - **Documentation improvement.** Most of the comments in the script (mainly in the top parameters block) haven't been edited since the original 2018 version, and may be unfriendly to non-technical users who just wish to use this script once to clean up a PDF quickly and fix the "active content" email bounce-back error they've been getting. This includes install instructions in this very README, which could be explained a bit better in a *"don't make me think"* sort of way. I try to avoid writing such instructional guides anymore, but perhaps this will appeal to a larger audience, and I tend to only use this tool once every 2 years myself (when I'm sending out resumes) so I forget what the hell I was doing here regularly as well. **Tracked in GitHub** [**Issue #4**](https://github.com/Kerbalnut/Sanitize-PDF/issues/4)
 
## Thanks to:

 - Go to [Secruity.SE][1] and upvote that question for having such an awesome, accurate, functional answer in it. I basically copied and pasted their work verbatim. 
 - [PDFSAM Basic][2] is a free PDF Split-And-Merge tool, functionality normally only found in paid-for software. I use it all the time and never paid them a dime, so the best I can do for now is promote them for being awesome. Use it, share them on social media, and don't forget you can install [via Chocolatey](https://chocolatey.org/packages/pdfsam): `choco install pdfsam -y`
 - [Chocolatey](https://chocolatey.org) is an awesome tool for automating installing, uninstalling, updating, and managing software versions. You can install packages from their public repository, from a local source, or set up your own repository for internal use. They offer Pro and Business [editions](https://chocolatey.org/pricing) with virus scanning features and more, but the main functionality is always free.
 - And of course, the star of the show: [Ghostscript](https://ghostscript.com/)! Promote them on social media, help contribute if you know how, or help them bug test. A shout-out to all the folks who helped with this project for being awesome. 

## How to Contribute:

1. Send me [feature requests](https://github.com/Kerbalnut/Sanitize-PDF/issues) and [bug reports](https://github.com/Kerbalnut/Sanitize-PDF/issues) if you like. No promises on delivery dates though. 
2. [Fork this repository](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-forks) on GitHub, then [clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository-from-github) to your local machine. I recommend installing both [GitHub Desktop](https://desktop.github.com/) and [TortoiseGit](https://tortoisegit.org/) to help you interact with git repos, or [VS Code](https://code.visualstudio.com/) for an all-in-one solution with it being an IDE (code editor), split-screen markdown editor, and git-integrated. (Or all three, which can all be installed via [chocolatey](https://chocolatey.org/install): `choco install github-desktop tortoisegit vscode -y`) In your forked repo, you can create/publish/merge branches, pull updates from this parent repo, and when ready to share your changes, submit a [pull request from your fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).

## Disclaimer:

This script is not intended to remove all/any malware from any PDF or any other document, and makes no such promises, and offers no warranty. Use at your own risk. See the [LICENSE](https://github.com/Kerbalnut/Sanitize-PDF/blob/master/LICENSE) attached to this repository for full legal information. I've chosen the MIT license so this repo may be cloned, modified, and distributed within any organization free of charge, the only requirement being preservation of copyright and license notices. See [choosealicense.com/licenses/mit/](https://choosealicense.com/licenses/mit/) for a quick overview analysis of this license. However if you do make any signficant improvements that you don't mind sharing, you're always encouraged to submit a [Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) through GitHub to help contribute to this project.

[1]: https://security.stackexchange.com/questions/103323/effectiveness-of-flattening-a-pdf-to-remove-malware
[2]: https://pdfsam.org/download-pdfsam-basic/

