import sys
import os
import getopt
import subprocess

def usage():
    print("Usage: python snes_bin_mod.py [-o output_folder] jpg_file_directory")

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:", ["help", "output="])
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(2)
    if len(args) != 1:
        print("jpg folder expected!", file=sys.stderr)
        sys.exit(1)
    jpg_folder = args[0]
    output_folder = jpg_folder
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-o", "--output"):
            output_folder = a
        else:
            assert False, "unhandled option"
    file_list = []
    for root, dirs, files in os.walk(jpg_folder):
        for file in files:
            if file.endswith(".jpg"):
                file_list.append(os.path.join(root, file))
    for input_file in file_list:
        file_title, _ = os.path.splitext(os.path.basename(input_file))
        output_file = os.path.join(output_folder, file_title + ".pcx")
        # cmd = ["convert", input_file, "-resize", "256x224", "-background", "Black", "-gravity", "center", "-extent", "256x224", "-colors", "256", output_file]
        # cmd = ["magick", input_file, "-resize", "256x224", "-background", "Black", "-gravity", "center", "-extent", "256x224", "-colors", "256", output_file]
        cmd = ["magick", input_file, "-filter", "Mitchell", "-resize", "256x224", "-background", "Black", "-gravity", "center", "-extent", "256x224", "-colors", "256", output_file]
        result = subprocess.Popen(cmd)
        text = result.communicate()[0]
        return_code = result.returncode
        if return_code != 0:
            print(text)
            print(" ".join(cmd))

    sys.exit(0)

if __name__ == '__main__':
    main()
