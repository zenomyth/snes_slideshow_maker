import sys

def main():
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
            # print('    <td bgcolor="#{:02X}{:02X}{:02X}"></td>'.format(y, x, 223 - x))
            print('    <td bgcolor="#{:02X}{:02X}{:02X}"></td>'.format(y // 8 * 8, x // 8 * 8, (223 - x) // 8 * 8))
        print('  </tr>')
    print('</table>')
    print('</body>')
    print('</html>')
    sys.exit(0)

if __name__ == '__main__':
    main()
