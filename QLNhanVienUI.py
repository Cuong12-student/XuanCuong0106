import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
import matplotlib
import warnings
warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy")
matplotlib.use('TkAgg')

class LoginWindow:
    def __init__(self, parent):
        self.parent = parent
        self.parent.title("ĐĂNG NHẬP HỆ THỐNG QUẢN LÝ NHÂN SỰ")
        self.parent.geometry("500x600")
        self.parent.resizable(False, False)
        self.parent.configure(bg="#1e3a8a")
         # Căn giữa màn hình
        self.parent.state('zoomed')  
        
        # Frame chính
        main_frame = tk.Frame(self.parent, bg="#1e3a8a")
        main_frame.pack(expand=True)
        
        # Logo + Tiêu đề
        tk.Label(main_frame, text="QUẢN LÝ NHÂN SỰ", font=("Segoe UI", 28, "bold"),
                 bg="#1e3a8a", fg="white").pack(pady=40)
        tk.Label(main_frame, text="Đăng nhập để tiếp tục", font=("Segoe UI", 12),
                 bg="#1e3a8a", fg="#a0aec0").pack(pady=10)
        
        # Frame nhập liệu
        form = tk.Frame(main_frame, bg="white", padx=40, pady=40, relief=tk.RAISED)
        form.pack(pady=20, ipadx=20, ipady=30)
        
        tk.Label(form, text="Tên đăng nhập", font=("Segoe UI", 12), bg="white").pack(anchor="w")
        self.entry_user = tk.Entry(form, font=("Segoe UI", 14), width=25, relief=tk.FLAT, bg="#edf2f7")
        self.entry_user.pack(pady=8, ipady=10)
        #self.entry_user.insert(0, "admin")
        
        tk.Label(form, text="Mật khẩu", font=("Segoe UI", 12), bg="white").pack(anchor="w", pady=(20,0))
        self.entry_pass = tk.Entry(form, font=("Segoe UI", 14), width=25, show="•", relief=tk.FLAT, bg="#edf2f7")
        self.entry_pass.pack(pady=8, ipady=10)
        #self.entry_pass.insert(0, "admin") 
        
        # Nút đăng nhập đẹp
        btn_login = tk.Button(form, text="ĐĂNG NHẬP", font=("Segoe UI", 14, "bold"),
                              bg="#10b981", fg="white", relief=tk.FLAT, cursor="hand2",
                              command=self.check_login)
        btn_login.pack(pady=25, ipady=12, ipadx=40)
        
        # SỬA LỖI: Thêm đúng event cho hover
        btn_login.bind("<Enter>", lambda e: btn_login.config(bg="#059669"))
        btn_login.bind("<Leave>", lambda e: btn_login.config(bg="#10b981"))
        
        # Phím Enter cũng đăng nhập được
        self.parent.bind("<Return>", lambda e: self.check_login())
    
    def check_login(self):
        username = self.entry_user.get().strip()
        password = self.entry_pass.get().strip()
        
        if username == "admin" and password == "admin":
            messagebox.showinfo("THÀNH CÔNG", "Đăng nhập thành công! Chào mừng Admin!")
            self.parent.withdraw()  # Ẩn cửa sổ login
            main_window = tk.Toplevel()
            QLNhanVienUI(main_window)  # Mở giao diện chính
        else:
            messagebox.showerror("LỖI ĐĂNG NHẬP", "Sai tên đăng nhập hoặc mật khẩu!\nGợi ý: admin / admin")
            self.entry_pass.focus()

class QLNhanVienUI:
    def __init__(self, root):
        self.root = root
        self.root.title("HỆ THỐNG QUẢN LÝ NHÂN SỰ - ĐỒ ÁN HOÀN CHỈNH")
        self.root.state('zoomed')
        self.root.configure(bg="#f0f2f5")

        try:
            self.conn = pyodbc.connect(
                "DRIVER={ODBC Driver 17 for SQL Server};"
                "SERVER=(localdb)\\MSSQLLocalDB;"
                "DATABASE=QLNhanVienDB;"
                "Trusted_Connection=yes;"
            )
            print("Kết nối SQL Server thành công!")
        except Exception as e:
            messagebox.showerror("LỖI KẾT NỐI", f"Không kết nối được CSDL!\n{e}")
            return

        self.setup_ui()
        self.yeucau0()

    def lighten_color(self, hex_color):
        """Làm sáng màu lên khi hover"""
        hex_color = hex_color.lstrip('#')
        r, g, b = [int(hex_color[i:i+2], 16) for i in (0, 2, 4)]
        r = min(255, int(r * 1.25))
        g = min(255, int(g * 1.25))
        b = min(255, int(b * 1.25))
        return f"#{r:02x}{g:02x}{b:02x}"
    
    def setup_ui(self):
        # HEADER
        header = tk.Frame(self.root, bg="#1e3a8a", height=90)
        header.pack(fill=tk.X)
        header.pack_propagate(False)
        tk.Label(header, text="HỆ THỐNG QUẢN LÝ NHÂN SỰ", font=("Segoe UI", 26, "bold"),
                 bg="#1e3a8a", fg="white").pack(pady=20)

                # SCROLLABLE BUTTONS
        btn_container = tk.Frame(self.root, bg="#f8fafc")
        btn_container.pack(fill=tk.X, pady=10)

        canvas = tk.Canvas(btn_container, height=80, bg="#f8fafc", highlightthickness=0)
        scrollbar = ttk.Scrollbar(btn_container, orient="horizontal", command=canvas.xview)
        scroll_frame = tk.Frame(canvas, bg="#f8fafc")
        scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")
        canvas.configure(xscrollcommand=scrollbar.set)
        canvas.pack(side=tk.TOP, fill=tk.X, expand=True)
        scrollbar.pack(side=tk.BOTTOM, fill=tk.X)

        # 9 NÚT ĐẸP - DÙNG ĐÚNG VIEW/FUNCTION CỦA BẠN
        buttons = [
            ("0. Toàn bộ nhân viên",        self.yeucau0, "#2c3e50"),
            ("1. NV nữ ≥6 tháng",           self.yeucau1, "#e74c3c"),
            ("2. HĐ sắp hết (≤30 ngày)",    self.yeucau2, "#f39c12"),
            ("3. Lương + phụ cấp theo PB",  self.yeucau3, "#27ae60"),
            ("4. Số NV theo loại HĐ",       self.yeucau4, "#3498db"),
            ("5. Quỹ lương từng phòng",     self.yeucau5, "#9b59b6"),
            ("6. Phòng lương Max/Min",      self.yeucau6, "#e67e22"),
            ("7. Nam ≤27 tuổi",             self.yeucau7, "#34495e"),
            ("8. Làm việc ≥2 năm",          self.yeucau8, "#8e44ad"),
            ("9. Trigger nâng hệ số",       self.yeucau9, "#c0392b"),
        ]

        for text, cmd, color in buttons:
            btn = tk.Button(scroll_frame, text=text, command=cmd, bg=color, fg="white",
                          font=("Segoe UI", 11, "bold"), width=26, height=2, relief=tk.FLAT,
                          highlightthickness=0, bd=0)
            btn.pack(side=tk.LEFT, padx=6)
            btn.bind("<Enter>", lambda e, b=btn, c=color: b.config(bg=self.lighten_color(c)))
            btn.bind("<Leave>", lambda e, b=btn, c=color: b.config(bg=c))

        # MAIN CONTENT
        main = tk.Frame(self.root)
        main.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)

        left = tk.Frame(main, bg="white", relief=tk.RAISED, bd=2)
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0,10))
        tk.Label(left, text="KẾT QUẢ", font=("Segoe UI", 16, "bold"), bg="white").pack(pady=10)

        self.tree = ttk.Treeview(left, show="headings")
        v_scroll = ttk.Scrollbar(left, orient="vertical", command=self.tree.yview)
        h_scroll = ttk.Scrollbar(left, orient="horizontal", command=self.tree.xview)
        self.tree.configure(yscrollcommand=v_scroll.set, xscrollcommand=h_scroll.set)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=10)
        v_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        h_scroll.pack(side=tk.BOTTOM, fill=tk.X)

        self.right_frame = tk.Frame(main, bg="white", relief=tk.RAISED, bd=2, width=520)
        self.right_frame.pack(side=tk.RIGHT, fill=tk.BOTH)
        self.right_frame.pack_propagate(False)
        tk.Label(self.right_frame, text="BIỂU ĐỒ", font=("Segoe UI", 16, "bold"), bg="white").pack(pady=10)
        self.chart_frame = tk.Frame(self.right_frame, bg="#ecf0f1")
        self.chart_frame.pack(fill=tk.BOTH, expand=True, padx=15, pady=10)

        self.status = tk.StringVar(value="Sẵn sàng – Chọn chức năng để thực hiện!")
        tk.Label(self.root, textvariable=self.status, bg="#27ae60", fg="white",
                 font=("Segoe UI", 11), anchor="w", padx=20).pack(side=tk.BOTTOM, fill=tk.X)

    def load_table(self, df):
        for i in self.tree.get_children(): self.tree.delete(i)
        if df.empty:
            self.status.set("Không có dữ liệu!")
            return
        cols = list(df.columns)
        self.tree["columns"] = cols
        for col in cols:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=150, anchor="center")
        for _, row in df.iterrows():
            values = [f"{x:,.0f}" if isinstance(x, (int,float)) and abs(x) > 1000 else x for x in row]
            self.tree.insert("", "end", values=values)

    def plot_chart(self, df):
        self.clear_chart(show=True)  # HIỆN khung biểu đồ
        
        if 'QuyLuong' not in df.columns:
            return
        
        fig, ax = plt.subplots(figsize=(8, 5.5))
        bars = ax.bar(df['TenPB'], df['QuyLuong']/1e6, color='#2ecc71')
        ax.set_title('QUỸ LƯƠNG THEO PHÒNG BAN (triệu VNĐ)', fontweight='bold', fontsize=14)
        ax.set_ylabel('Triệu VNĐ', fontsize=12)
        ax.tick_params(axis='x', rotation=45)
        for bar in bars:
            h = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2, h + 5, f'{h:.0f}tr', 
                    ha='center', fontweight='bold', fontsize=11)
        plt.tight_layout()
        
        canvas = FigureCanvasTkAgg(fig, self.chart_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        NavigationToolbar2Tk(canvas, self.chart_frame)

    def clear_chart(self, show=False):
        # Xóa hết biểu đồ cũ
        for widget in self.chart_frame.winfo_children():
            widget.destroy()
        
        # Nếu không muốn hiện biểu đồ → ẨN TOÀN BỘ KHUNG PHẢI
        if not show:
            self.right_frame.pack_forget()  # Ẩn hoàn toàn khung biểu đồ
        else:
            # Nếu muốn hiện → hiện lại khung (nếu đang bị ẩn)
            if not self.right_frame.winfo_ismapped():
                self.right_frame.pack(side=tk.RIGHT, fill=tk.BOTH)
    
    # TẤT CẢ DÙNG ĐÚNG VIEW/FUNCTION CỦA BẠN
    def yeucau0(self):
        df = pd.read_sql("SELECT * FROM NhanVien ORDER BY MaNV", self.conn)
        self.load_table(df)
        self.clear_chart()
        self.status.set(f"0: Toàn bộ nhân viên – Tổng cộng: {len(df)} người")
    def yeucau1(self): df = pd.read_sql("SELECT * FROM V_NhanVienNu_6Thang", self.conn); self.load_table(df);self.clear_chart(show=False); self.status.set(f"1: {len(df)} nữ ≥6 tháng")
    def yeucau2(self): df = pd.read_sql("SELECT * FROM V_SapHetHanHopDong", self.conn); self.load_table(df);self.clear_chart(show=False); self.status.set(f"2: {len(df)} HĐ sắp hết")
    def yeucau3(self): df = pd.read_sql("SELECT * FROM V_Luong_TheoPhong", self.conn); self.load_table(df);self.clear_chart(show=False); self.status.set("3: Lương + phụ cấp")
    def yeucau4(self): df = pd.read_sql("SELECT * FROM V_SoNhanVien_TheoLoaiHD", self.conn); self.load_table(df);self.clear_chart(show=False); self.status.set("4: Số lượng theo loại HĐ")
    def yeucau5(self): df = pd.read_sql("SELECT * FROM V_QuyLuong_Phong ORDER BY QuyLuong DESC", self.conn); self.load_table(df); self.plot_chart(df); self.status.set("5: Quỹ lương từng phòng")
    
    def yeucau6(self):
        df = pd.read_sql("SELECT * FROM V_Phong_QuyLuong_TongHop ORDER BY QuyLuong DESC", self.conn)
        self.load_table(df)
        self.clear_chart(show=False)         
        max_pb = df[df['LoaiQuyLuong'] == 'Max'].iloc[0]
        min_pb = df[df['LoaiQuyLuong'] == 'Min'].iloc[0]
        self.status.set(f"6: Phòng lương CAO NHẤT: {max_pb['TenPB']} ({max_pb['QuyLuong']:,.0f}đ) | "
                        f"THẤP NHẤT: {min_pb['TenPB']} ({min_pb['QuyLuong']:,.0f}đ)")

    def yeucau7(self): df = pd.read_sql("SELECT * FROM V_NVNam_Tuoi27", self.conn); self.load_table(df);self.clear_chart(show=False); self.status.set(f"7: {len(df)} nam ≤27 tuổi")
    
    def yeucau8(self):
        # DÙNG ĐÚNG FUNCTION CỦA BẠN + JOIN ĐÚNG TÊN CỘT
        df = pd.read_sql("select * from V_ThamNien_2Nam", self.conn)
        self.load_table(df)
        self.clear_chart(show=False)
        self.status.set(f"8: {len(df)} nhân viên ≥2 năm")

    def yeucau9(self):
        messagebox.showinfo("YÊU CẦU 9", 
            "Trigger 'trg_Luong_CapNhatHeSoPhuCapThamNien' đang hoạt động!\n\n"
            "→ Tự động +0.5 hệ số khi nhân viên đủ 24 tháng\n"
            "→ Chỉ tăng 1 lần (điều kiện HeSoPhuCap < 2.5)\n\n"
            "Test: UPDATE HopDong SET NgayBatDau='2020-01-01' WHERE MaNV='NV03'")
        self.status.set("9: Trigger tự động đang chạy!")

# THAY ĐỔI PHẦN NÀY
if __name__ == "__main__":
    root = tk.Tk()
    login = LoginWindow(root)  
    root.mainloop()
    # XÓA DÒNG CŨ: app = QLNhanVienUI(root)