all: index.html
%.html: %.pug ; pug $<
%.html: %.md template/page.html ; pandoc --template template/page.html -o $@ $<
