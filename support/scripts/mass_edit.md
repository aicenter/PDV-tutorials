# Commands for editing of all files at once

Replace paths in tex files:

```bash
for i in {01..13}
do
sed -i "s|../commands.tex|commands.tex|" $i.tex
done
```

Replace paths to corresponding individual folders:

```
for i in {01..13}
do
sed -i "s|{fig|{$i/fig|" $i.tex
done
```