import xml.etree.ElementTree as ET
import pymol
from pymol import cmd

# message for debug
def debug_message(message):
    print(f"DEBUG: {message}")

# open PyMOL
pymol.finish_launching()

# import xml file (output of PISA)
try:
    tree = ET.parse('/path/to/residue1.xml')
    root = tree.getroot()
    debug_message("XML file parsed successfully.")
except Exception as e:
    debug_message(f"Failed to parse XML file: {e}")

# setting of color map
def get_color(value, min_value, max_value):
    norm_value = (value - min_value) / (max_value - min_value)
    return [norm_value, 0.1, 1-norm_value]

# coloring each residue
for residue in root.findall('.//RESIDUE'):
    try:
        structure = residue.find('STRUCTURE').text.strip()
        buried_surface_area = float(residue.find('BURIEDSURFACEAREASCORE').text.strip())
        
        # obtain chain and residue ids
        parts = structure.split()
        chain = parts[0][0]

        if chain == 'z':
            resi = parts[1]
            
        else:
            if len(parts) == 3:
                resi = parts[2]  # before 999
            else:
            	resi = parts[1][1:]  # after 1000
        
        if buried_surface_area == 0:
        	color = [0.9,0.9,0.9]
        else:
        	color = get_color(buried_surface_area, 0, 10)
        selection = f'chain {chain} and resi {resi}'
        cmd.set_color(f'color_{resi}', color)
        cmd.color(f'color_{resi}', selection)
        debug_message(f"Colored residue {chain} {resi} with BSA {buried_surface_area}.")
    except Exception as e:
        debug_message(f"Failed to process residue: {e}")


try:
    cmd.save('colored_structure.pse')
    debug_message("PSE file saved successfully.")
except Exception as e:
    debug_message(f"Failed to save PSE file: {e}")

