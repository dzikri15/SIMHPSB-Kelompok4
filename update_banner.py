import re

with open('d:\\SIMHPSB-Kelompok4\\banner.html', 'r', encoding='utf-8') as f:
    content = f.read()

# CSS replacement
css_replacement = """  /* ── FLOW DIAGRAM ── */
  .flow-area {
    position: relative; z-index: 10;
    padding: 32px 40px;
    border-bottom: 1px solid rgba(79,213,133,.1);
  }
  .flow-grid {
    display: flex;
    flex-direction: column;
    gap: 20px;
    position: relative;
    padding-left: 20px;
  }
  .flow-grid::before {
    content: '';
    position: absolute;
    top: 24px; bottom: 24px;
    left: 44px;
    width: 2px;
    background: rgba(79,213,133,.3);
    border-left: 2px dashed rgba(79,213,133,.6);
    z-index: 0;
  }
  .flow-step {
    display: flex;
    gap: 20px;
    align-items: flex-start;
    position: relative;
    z-index: 1;
    background: rgba(255,255,255,.02);
    border: 1px solid rgba(79,213,133,.15);
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.2);
  }
  .flow-step-number {
    width: 48px; height: 48px;
    border-radius: 50%;
    background: linear-gradient(145deg, #3ecf74, #1e6b40);
    display: flex; align-items: center; justify-content: center;
    font-size: 20px; font-weight: 900; color: #fff;
    flex-shrink: 0;
    box-shadow: 0 0 0 6px #0f2218, 0 0 0 8px rgba(79,213,133,.3);
    margin-top: 4px;
  }
  .flow-step-content {
    flex: 1;
  }
  .flow-step-title {
    font-size: 18px;
    font-weight: 800;
    color: #fff;
    margin-bottom: 8px;
    display: flex; align-items: center; gap: 8px;
  }
  .flow-step-title span {
    font-size: 10px;
    font-weight: 700;
    padding: 2px 6px;
    background: rgba(79,213,133,.15);
    color: #4fd585;
    border-radius: 4px;
    text-transform: uppercase;
    letter-spacing: .05em;
  }
  .flow-step-desc {
    font-size: 12px;
    color: rgba(255,255,255,.6);
    line-height: 1.6;
  }
"""

content = re.sub(r'/\* ── MOCKUP AREA ── \*/.*?/\* ── FEATURES ── \*/', css_replacement + '\n  /* ── FEATURES ── */', content, flags=re.DOTALL)

# HTML replacement
html_replacement = """  <!-- ── ALUR SISTEM ── -->
  <div class="flow-area">
    <div class="section-label">Alur Bisnis & Sistem</div>
    <div class="flow-grid">
      
      <div class="flow-step">
        <div class="flow-step-number">1</div>
        <div class="flow-step-content">
          <div class="flow-step-title">Petani Memasok Gabah <span>Input via Aplikasi</span></div>
          <div class="flow-step-desc">
            Petani/Mitra memanen padi di sawah dan melaporkan hasil panen (gabah) ke dalam sistem menggunakan aplikasi mobile, lengkap dengan bukti foto.
          </div>
        </div>
      </div>

      <div class="flow-step">
        <div class="flow-step-number">2</div>
        <div class="flow-step-content">
          <div class="flow-step-title">Penggilingan & Masuk Gudang <span>Manajemen Stok</span></div>
          <div class="flow-step-desc">
            Gabah diterima di gudang (penggilingan Silvy Halimatusyadiah). Proses penggilingan mengubah gabah menjadi beras. Sistem secara otomatis mencatat mutasi penambahan saldo beras.
          </div>
        </div>
      </div>

      <div class="flow-step">
        <div class="flow-step-number">3</div>
        <div class="flow-step-content">
          <div class="flow-step-title">Distribusi ke Tujuan <span>Tracking Keluar</span></div>
          <div class="flow-step-desc">
            Beras yang siap jual didistribusikan ke berbagai tujuan (pasar/toko). Petugas mencatat jumlah beras keluar beserta tujuan armada untuk menjaga akurasi stok gudang.
          </div>
        </div>
      </div>

      <div class="flow-step">
        <div class="flow-step-number">4</div>
        <div class="flow-step-content">
          <div class="flow-step-title">Monitoring Pimpinan <span>Dashboard & AI</span></div>
          <div class="flow-step-desc">
            Seluruh alur dari awal panen hingga distribusi terpantau real-time oleh Pimpinan di Dashboard Web. Pimpinan juga dapat bertanya sisa stok secara instan kepada HPSBBot (AI).
          </div>
        </div>
      </div>

    </div>
  </div>
"""

content = re.sub(r'<!-- ── MOCKUP ── -->.*?<!-- ── FEATURES ── -->', html_replacement + '\n  <!-- ── FEATURES ── -->', content, flags=re.DOTALL)

with open('d:\\SIMHPSB-Kelompok4\\banner.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Banner updated successfully!")
