import sys

def main():
    # filename = 'Great_Wave_off_Kanagawa2.pcx'
    filename = 'kyoto.pcx'
    with open(filename, mode='rb') as file:
        content = file.read()
    # print(type(content))
    # print(content[len(content) - 1 - 256 * 3])
    i = 0x80
    img_data = []
    while True:
        if i == len(content) - 1 - 256 * 3:
            break
        if content[i] & 0xC0 == 0xC0:
            for j in range(content[i] & 0x3F):
                img_data.append(content[i + 1])
            i = i + 1
        else:
            img_data.append(content[i])
        i = i + 1
    # print(len(img_data))
    palette = []
    for i in range(256):
        palette.append("{:02X}{:02X}{:02X}".format(content[len(content) - 256 * 3 + i * 3] // 8 * 8, content[len(content) - 256 * 3 + i * 3 + 1] // 8 * 8, content[len(content) - 256 * 3 + i * 3 + 2] // 8 * 8))
    # print(palette)

    print('<!DOCTYPE html>')
    print('<html>')
    print('<head>')
    print('<style>')
    print('table, td {')
    # print('  border: 1px solid black;')
    print('  border-spacing:0;')
    print('  border-collapse: collapse;')
    print('}')
    print('td {')
    print('  height: 1px;')
    print('  width: 1px;')
    print('}')
    print('</style>')
    print('</head>')
    print('<body>')
    print('<table>')
    for x in range(224):
        print('  <tr>')
        for y in range(256):
            print('    <td bgcolor="#{}"></td>'.format(palette[img_data[256 * x + y]]))
            # print('    <td bgcolor="#{:02X}{:02X}{:02X}"></td>'.format(y // 8 * 8, x // 8 * 8, (223 - x) // 8 * 8))
        print('  </tr>')
    print('</table>')
    print('</body>')
    print('</html>')

    sys.exit(0)

if __name__ == '__main__':
    main()
