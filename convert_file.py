files = ['words5.txt', 'words6.txt', 'words7.txt', 'words8.txt']
for file in files:
    try:
        with open(file, 'r') as inp:
            resultString = ''
            k = 0
            for line in inp.readlines():
                resultString += line.upper()
                k += 1       

        resultString = str(k) + '\n' + resultString
        
        with open(file, 'w') as out:
            out.write(resultString)
        print('Данные успешно перезаписаны в файл!')
            
    except FileNotFoundError:
        print('Нет такого файла в директории! Попробуйте еще раз')