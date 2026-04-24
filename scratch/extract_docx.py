import xml.etree.ElementTree as ET
import os
import sys

# Set encoding to utf-8 for stdout
sys.stdout.reconfigure(encoding='utf-8')

def extract_text(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    # Namespaces
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    texts = []
    for p in root.findall('.//w:p', ns):
        p_text = ""
        for t in p.findall('.//w:t', ns):
            if t.text:
                p_text += t.text
        if p_text:
            texts.append(p_text)
    return texts

xml_path = r'd:\hk2_25_26\Thực tập tốt nghiệp\flutter_application_baithi\temp_docx\word\document.xml'
if os.path.exists(xml_path):
    all_text = extract_text(xml_path)
    for i, line in enumerate(all_text):
        print(f"{i}: {line}")
else:
    print("File not found")
