import pycdlib
import os

path=os.getcwd()
file=os.path.join(path, 'preseed.cfg')
print(file, path)

iso = pycdlib.PyCdlib()
iso.new()
iso.add_file(file, iso_path='/PRESEED.CFG')
iso.write('preseed.iso')
iso.close()
