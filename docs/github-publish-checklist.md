# GitHub 发布检查清单

## 发布前检查

- [ ] `README.md` 已写清安装方式
- [ ] `CHANGELOG.md` 已记录首版内容
- [ ] `LICENSE` 已确认
- [ ] `RELEASE.md` 已准备发布说明
- [ ] 所有脚本已 `chmod +x`
- [ ] 所有脚本已通过 `bash -n` 语法检查
- [ ] 默认版本 TAG 已确认
- [ ] README 中的仓库名、命令、路径无误

## 建议发布步骤

```bash
git init
git add .
git commit -m "feat: initial release of dujiao-next-one-click"
```

如果你要推到 GitHub：

```bash
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```
