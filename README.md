# Ansible Pull 模式示例

這個專案是 Ansible Pull 模式的基本示例，用於示範如何使用 Ansible 的 pull 方法來管理伺服器配置。

```
docker build -t ansible-ubuntu-server . && docker run --name server1 -d -p 8888:22 ansible-ubuntu-server
```

## Edge

```
ansible-pull -U https://github.com/YutangShi/ansible-pull-mode.git
```

## 什麼是 Ansible Pull 模式？

Ansible 通常以「推送」（Push）模式運作，由中央控制伺服器連接到多個目標機器並執行配置任務。相反，Ansible 的「拉取」（Pull）模式由每台目標機器主動從版本控制系統拉取 Ansible 程式碼並在本地執行。

### Pull 模式的優點：

- **高度可擴展性**：適合管理大量伺服器，無需中央伺服器建立多個 SSH 連線
- **無需中央控制**：每台伺服器可以獨立運作
- **適合動態 IP 環境**：目標機器可以位於 NAT 後或擁有動態 IP
- **適合無法 SSH 的環境**：當無法從中央伺服器直接 SSH 到目標機器時很有用
- **異步執行**：各伺服器可以在不同時間點執行更新

### Pull 模式的限制：

- **需要在每台機器上安裝 Ansible**
- **無法立即應用變更**（通常透過 cron 定期執行）
- **難以集中查看執行結果**
- **需要管理敏感資料存取權限**

## 使用方法

### 初始安裝

在新伺服器上，執行以下命令來安裝並設置 Ansible Pull 機制：

```bash
curl -s https://raw.githubusercontent.com/your-org/ansible-repo/main/setup-pull.sh | sudo bash
```

或者，如果已下載此儲存庫：

```bash
sudo bash setup-pull.sh
```

### 手動執行

初始安裝後，您可以隨時手動執行 Ansible Pull 以立即套用配置：

```bash
sudo ansible-pull -U https://github.com/your-org/ansible-repo.git
```

使用 `-o` 參數可以讓 Ansible 只在儲存庫有變更時才運行：

```bash
sudo ansible-pull -o -U https://github.com/your-org/ansible-repo.git
```

## 專案結構

```
ansible-pull-example/
├── local.yml              # Ansible Pull 的主要入口點
├── hosts                  # Inventory 檔案
├── setup-pull.sh          # 初始安裝腳本
├── roles/
│   └── server_config/     # 基本伺服器配置角色
│       ├── tasks/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       └── templates/
│           └── ssh_config.j2
```

## 客製化

1. 修改 `local.yml` 以包含您需要的角色和任務
2. 更新 `setup-pull.sh` 中的儲存庫 URL
3. 根據需要添加新的角色和任務

## 最佳實踐

1. **版本控制**：確保所有 Ansible 程式碼都受到版本控制
2. **敏感資料**：避免將密碼等敏感資料直接放在版本控制庫中，考慮使用 Ansible Vault 或外部密碼管理系統
3. **日誌處理**：設置集中日誌收集以追蹤各伺服器的執行情況
4. **測試**：在實際部署前，先在測試環境中測試您的 Ansible Pull 配置

## 故障排除

如果遇到問題，請檢查以下日誌檔案：

```bash
cat /var/log/ansible-pull.log
```

## 參考資料

- [Ansible Pull 官方文件](https://docs.ansible.com/ansible/latest/cli/ansible-pull.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) 