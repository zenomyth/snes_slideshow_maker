import sys

def main():
    # filename = 'Great_Wave_off_Kanagawa2.pcx'
    # filename = 'kyoto.pcx'
    filename = 'KJ.pcx'
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

    palette = bytearray()
    for i in range(256):
        palette.append((content[len(content) - 256 * 3 + i * 3] >> 3) | ((content[len(content) - 256 * 3 + i * 3 + 1] >> 3 << 5) & 0xFF))
        palette.append(((content[len(content) - 256 * 3 + i * 3 + 1] >> 6) & 0xFF) | ((content[len(content) - 256 * 3 + i * 3 + 2] >> 3 << 2) & 0xFF))
    with open('03_palette.dat', mode='wb') as file:
        file.write(palette)

    tiles = bytearray(256 * 224)
    for i in range(224):
        for j in range(256):
            px = img_data[i * 256 + j]
            t_idx = (i // 8) * 32 + (j // 8)
            ii = i % 8
            jj = j % 8
            for k in range(8):
                if px & 1 == 1:
                    tiles[64 * t_idx + k // 2 * 16 + ii * 2 + k % 2] = tiles[64 * t_idx + k // 2 * 16 + ii * 2 + k % 2] | (1 << (7 - jj))
                px = px >> 1
    with open('03_tiles.dat', mode='wb') as file:
        file.write(tiles)

    sys.exit(0)

if __name__ == '__main__':
    main()
