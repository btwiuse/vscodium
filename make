false && {
	convert -background none -density 1200 -resize 512x512 codigo.svg android-chrome-512x512.png
	convert -background none -density 1200 -resize 300x300 codigo.svg android-chrome-300x300.png
	convert -background none -density 1200 -resize 192x192 codigo.svg android-chrome-192x192.png
	convert -background white -density 1200 -resize 180x180 codigo.svg apple-touch-icon.png
	convert -background none -density 1200 -resize 16x16 codigo.svg favicon-16x16.png
	convert -background none -density 1200 -resize 32x32 codigo.svg favicon-32x32.png
	convert -background none -density 1200 -resize 16x16 codigo.svg favicon.ico
}

cp -v codigo.svg src/stable/src/vs/workbench/browser/media/code-icon.svg
cp -v codigo.svg icons/insider/
cp -v codigo.svg icons/stable/

magick convert -background black -density 1200 -resize 512x512 codigo.svg code-512-dark.png
magick convert -background black -density 1200 -resize 192x192 codigo.svg code-192-dark.png
magick convert -background white -density 1200 -resize 512x512 codigo.svg code-512.png
magick convert -background white -density 1200 -resize 192x192 codigo.svg code-192.png
magick convert -background none -density 1200 -resize 32x32 codigo.svg favicon.ico

cp -v code-512-dark.png src/stable/resources/server/
cp -v code-192-dark.png src/stable/resources/server/
cp -v code-512.png src/stable/resources/server/
cp -v code-192.png src/stable/resources/server/
cp -v favicon.ico  src/stable/resources/server/
