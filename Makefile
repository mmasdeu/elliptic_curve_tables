all: tex

pdf: tex
	pdflatex test.tex

tex:
	sage make_table.sage

pull:
	scp hecke:darmonpoints/tables/input_file_tr.txt .
	scp hecke:darmonpoints/tables/input_file_atr.txt .

clean:
	rm -f *~
	rm -f test.aux
	rm -f test.log
	rm -f test.out
	rm -f make_table.py


