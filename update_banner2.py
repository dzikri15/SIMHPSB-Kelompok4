import re

with open('d:\\SIMHPSB-Kelompok4\\banner.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the Footer CSS so it centers the text
css_footer_replacement = """  /* ── FOOTER ── */
  .footer {
    position: relative; z-index: 10;
    padding: 16px 40px 24px;
    text-align: center;
  }
  .footer-left {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: center;
  }"""
content = re.sub(r'/\* ── FOOTER ── \*/.*?\.footer-left \{[^\}]+\}', css_footer_replacement, content, flags=re.DOTALL)


# 2. Extract the QR Code HTML
qr_match = re.search(r'    <!-- QR Code placeholder.*?</div>\s+</div>\s+</div>', content, re.DOTALL)
if qr_match:
    qr_code_html = qr_match.group(0)
    # Remove QR Code from footer
    content = content.replace(qr_code_html, '')
else:
    qr_code_html = ""

# 3. Update the Tech Stack section to include the QR Code
tech_stack_pattern = r'(<!-- ── TECH STACK ── -->\s*<div class="stack-section">)(.*?)(</div>\s*</div>)'
# We change <div class="stack-section"> to include flexbox
def replacer(m):
    start = m.group(1).replace('<div class="stack-section">', '<div class="stack-section" style="display: flex; justify-content: space-between; align-items: center;">\n    <div>')
    mid = m.group(2)
    end = '    </div>\n' + qr_code_html.replace('    <!-- QR Code', '    <!-- QR Code') + '\n  </div>'
    return start + mid + end

content = re.sub(tech_stack_pattern, replacer, content, flags=re.DOTALL)

with open('d:\\SIMHPSB-Kelompok4\\banner.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Banner updated successfully!")
