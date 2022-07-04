import sys
import os

def main():
    if len(sys.argv) != 2:
        print("jpg folder expected!", file=sys.stderr)
        sys.exit(1)
    jpg_folder = sys.argv[1]
    ext = '.jpg'
    ext2 = '.png'
    i = 1
    for root, dirs, files in os.walk(jpg_folder):
        for file in files:
            if file.endswith(ext) or file.endswith(ext2):
                cmd = "convert \"{fpath}\" -resize 256x224 -background Black -gravity center -extent 256x224 -colors 256 {i:02d}.pcx".format(fpath=os.path.join(root, file), i=i)
                print(cmd)
                i = i + 1
                # os.system(cmd)

    sys.exit(0)

if __name__ == '__main__':
    main()
