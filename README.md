# PDV

The repository with the tutorial sources for the distributed part now lives at https://github.com/aicenter/PDV-tutorials. Slides for the parallel part live in the main repo.

## Requirements

For beamer slides:
 - texlive for compiling tex files: `sudo apt-get install texlive texlive-latex-extra texlive-luatex texlive-fonts-extra texlive-lang-czechslovak`
 - pygments for syntax higlighting in slides: `sudo apt-get install python-pygments`
 - ipetoipe for converting images from .ipe to .pdf:  `sudo apt-get install ipe`

For editing graphics:
 - IPE editor: http://ipe.otfried.org/

## Editing

You can edit the Beamer slides in Overleaf at https://www.overleaf.com/project/62055881c2d6c95f912de323

## Usage
### Compiling slides
1. cd to the tutorial directory, e.g. `cd ./09`
2. Having the aliases set, run the compile script with `git make`

Notes:
 - Some tutorials may depend on figures in previous tutorials, so you need to build those first.
 - If not all figures are in pdf format, you can manually convert them to pdf first with ipetoipe (the compile script should take care of this for you):
```bash
for fig in figs/*.ipe
do
  ipetoipe -pdf "$fig"
done
```

 - To modify the feedback QR code to a new link, set the `\defaultfeedbackurl` in the `commands.tex` to the correct link.

### Online googleform quizes
Go to https://sites.google.com/a/fel.cvut.cz/quiz/, your cvut googleapps account has to be added to the PDV course.

### Online feedback form

**Deprecated**: Matej does not want to use the form any more.

There is one form for all tutorials, it is saved in the G-drive of the course. Use the `\framefeedback{}` command to include a slide. Don't forget to activate the form before classes and lock it afterwards.

## Github Actions Automated Compilation and Release
The repository is configured with a Github action that runs on every push. It is sufficient to push changes from overleaf, the pdfs linked from Courseware should get updated automatically in couple of minutes. Investigate failures by checking the Actions tab on github.
