import re


def print_table_latex(self, header_string = None, longtable = False, caption = None, hline_freq = None):
    r"""
    LaTeX representation of a table.

    If an entry is a Sage object, it is replaced by its LaTeX
    representation, delimited by dollar signs (i.e., ``x`` is
    replaced by ``$latex(x)$``). If an entry is a string, the
    dollar signs are not automatically added, so tables can
    include both plain text and mathematics.

    EXAMPLES::

        sage: from sage.misc.table import table
        sage: a = [[r'$\sin(x)$', '$x$', 'text'], [1,34342,3], [identity_matrix(2),5,6]]
        sage: latex(table(a)) # indirect doctest
        \begin{tabular}{lll}
        $\sin(x)$ & $x$ & text \\
        $1$ & $34342$ & $3$ \\
        $\left(\begin{array}{rr}
        1 & 0 \\
        0 & 1
        \end{array}\right)$ & $5$ & $6$ \\
        \end{tabular}
        sage: latex(table(a, frame=True, align='center'))
        \begin{tabular}{|c|c|c|} \hline
        $\sin(x)$ & $x$ & text \\ \hline
        $1$ & $34342$ & $3$ \\ \hline
        $\left(\begin{array}{rr}
        1 & 0 \\
        0 & 1
        \end{array}\right)$ & $5$ & $6$ \\ \hline
        \end{tabular}
    """
    from sage.misc.latex import latex, LatexExpr
    import types

    rows = self._rows
    nc = len(rows[0])
    if len(rows) == 0 or nc == 0:
        return ""

    align_char = self._options['align'][0]   # 'l', 'c', 'r'
    if self._options['frame']:
        frame_char = '|'
        frame_str = ' \\hline'
    else:
        frame_char = ''
        frame_str = ''
    if self._options['header_column']:
        head_col_char = '|'
    else:
        head_col_char = ''
    if self._options['header_row']:
        head_row_str = ' \\hline'
    else:
        head_row_str = ''

    # table header
    if longtable:
        s = "\\begin{longtable}[H]{"
    else:
        s = "\\begin{tabular}{"
    if header_string is None:
        s += frame_char + align_char + frame_char + head_col_char
        s += frame_char.join([align_char] * (nc-1))
        s += frame_char
    else:
        s += header_string
    s += "}" + frame_str + "\n"
    # first row
    s += " & ".join(LatexExpr(x) if isinstance(x, (str, LatexExpr))
                  else '$' + latex(x).strip() + '$' for x in rows[0])
    s += " \\tabularnewline" + frame_str + head_row_str
    if longtable and self._options['header_row']:
        s += "\\endhead\n"
    else:
        s += "\n"
    # other rows
    for i,row in enumerate(rows[1:]):
        s += " & ".join(LatexExpr(x) if isinstance(x, (str, LatexExpr))
                      else '$' + latex(x).strip() + '$' for x in row)
        if  hline_freq is not None and i % hline_freq == 1:
            s += " \\tabularnewline\\hline" + frame_str + "\n"
        else:
            s += " \\tabularnewline" + frame_str + "\n"

    if caption is not None:
        s += "\\caption{%s}\\\\\n"%caption
    if longtable:
        s += "\\end{longtable}"
    else:
        s += "\\end{tabular}"
    return s

max_rows = 2000
header_row = ['$|\\Delta_K|$','$f_K(x)$','$\\text{Nm}(\mathfrak{N})$','$\\mathfrak{p}\\mathfrak{D}\\mathfrak{m}$','$c_4(E),c_6(E)$']

def process_input(input_file,degree = 2):
    finp = open(input_file)
    x = QQ['x'].gen()
    r = QQ['r'].gen()
    rows0 = []
    counter = dict()
    counter['trials'] = 0
    counter['curves'] = 0
    counter['norational'] = 0
    counter['timeouts'] = 0
    counter['unrecognized']  = 0
    # counter['problemwp'] = 0
    counter['largep'] = 0
    counter['exceptions'] = 0
    for line in finp:
        line_orig = str(line)
        if line.startswith('#'): # Comment
            continue
        if line[0] != '[':
            continue
        if len(line) < 5: # Blank line
            continue
        # if not ', (' in line:
        #     continue
        line = line.split(",",1)[-1] # Remove first entry, which is useless
        line = line.split("],\\",1)[0] # Remove last characters, also useless
        # if line.count(",") < 10: # No success
        #     continue
        r = QQ['r'].gen()
        m = re.split(",",line,maxsplit = 5)
        if len(m) < 5:
            print 'Skipped line...'
            print line
            continue
        _,pol,P,D,Np,_ = m
        pol = sage_eval(pol,locals = {'x':x})
        if pol.degree() != degree:
            continue
        F.<r> = NumberField(pol)
        r = F.gen()
        P = F.ideal(sage_eval(P,locals = {'r':r}))
        D = F.ideal(sage_eval(D,locals = {'r':r}))
        Np = F.ideal(sage_eval(Np,locals = {'r':r}))
        # Now we classify the line
        counter['trials'] += 1
        if not ', (' in line:
            if re.search('timed out',line,re.IGNORECASE):
                counter['timeouts'] += 1
            elif "Group does not seem to be attached" in line:
                counter['norational'] += 1
            elif "None," in line:
                counter['unrecognized'] += 1
            elif "Trouble finding wp by enumeration" in line:
                counter['exceptions'] +=1
            elif "Prime too large to integrate" in line:
                counter['largep'] += 1
            else:
                counter['exceptions'] += 1
            continue
        else:
            counter['curves'] += 1
        m = re.search(r", (\(.*\))",line_orig)
        ainvs = tuple(sage_eval(m.groups()[0],locals = {'r':r}))
        E = EllipticCurve(F,list(ainvs))

        if P.is_one():
            Ptex = '(1)'
        else:
            Ptex = '(%s)_{%s}'%(latex(P.gens_reduced()[0]),P.norm())
        if D.is_one():
            Dtex = '(1)'
        else:
            Dtex = '(%s)_{%s}'%(latex(D.gens_reduced()[0]),D.norm())
        if Np.is_one():
            Nptex = '(1)'
        else:
            Nptex = '(%s)_{%s}'%(latex(Np.gens_reduced()[0]),Np.norm())
        factor_rep = '$%s %s %s$'%(Ptex,Dtex,Nptex)
        rows0.append([F.discriminant().abs(),'$%s$'%latex(pol.list()[:-1]),(P*D*Np).norm(),factor_rep,'$%s,$'%latex(E.c4()),'$%s$'%latex(E.c6())])
    finp.close()

    # Print statistics
    rows = []
    rows.append(['Found curves',counter['curves'],'Time outs',counter['timeouts']])
    rows.append(['No rational lines',counter['norational'],'Not recognized',counter['unrecognized']])
    rows.append(['Total Trials',counter['trials'],'$\\fp$ too large',counter['largep']])
    rows.append(['','','Runtime errors',counter['exceptions']])

    output_name = input_file.replace('input','output').replace('.txt','_%s.tex'%degree)
    fout = open(output_name,'w')
    fout.write('\n')
    fout.write(print_table_latex(table(rows),longtable = True, caption = 'Statistics', header_string = 'lrlr'))
    fout.write('\n')

    rows0 = list(sorted(rows0,key = lambda x:x[0].abs()))
    rows = []
    for row in rows0:
        row1 = row[:-1]
        row2 = ['','','','',row[-1]]
        rows.extend([row1,row2])

    num_rows = len(rows)
    header_string = 'rp{1.3cm}rlp{7cm}'
    fout.write('{\\tiny\n')
    for i in range(0,num_rows,2*max_rows):
        fout.write(print_table_latex(table(rows[i:i+2*max_rows],header_row = header_row),header_string = header_string, longtable = True, caption = 'Fields of degree %s'%degree,hline_freq = 2))
    fout.write('\n}\n')
    fout.close()

process_input('input_file_atr.txt',2)
process_input('input_file_atr.txt',3)
process_input('input_file_atr.txt',4)
process_input('input_file_tr.txt',2)
process_input('input_file_tr.txt',3)

