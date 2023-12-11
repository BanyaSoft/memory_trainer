files = ['words5.txt', 'words6.txt', 'words7.txt', 'words8.txt']
for file in files:
    try:
        with open(file, 'r', encoding='ANSI') as inp:
            resultString = ''  
            k = 0
            first_line = inp.readline()

            try:
                count = int(first_line)
            except ValueError:
                resultString += first_line.upper()
                k += 1

            for line in inp.readlines():
                resultString += line.upper()
                k += 1
        
        resultString = str(k) + '\n' + resultString
        
        with open(file, 'w', encoding='ANSI') as out:
            out.write(resultString)
            
        print('Everything is good!')
            
    except FileNotFoundError:
        print('There is no such file in the directory. Try again.')