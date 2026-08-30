BULIDICS Skill インストールキット v1.1.0
==================================================

■ 対応環境

  ・Codex
  ・Cursor
  ・Claude Code
  ・Windows 10 / Windows 11


■ インストール方法

  1. ZIPファイルを任意のフォルダーへ展開します。
  2. install.cmdをダブルクリックします。
  3. 画面に表示されるインストール先と進捗を確認します。
  4. 「インストールが正常に完了しました」と表示されたらキーを押します。
  5. Cursor、Codex、Claude Codeを再起動します。
  6. verify.cmdをダブルクリックして、すべて「OK」になることを確認します。

管理者権限は不要です。

インストール画面には、次の内容が表示されます。

  ・Codex / Cursor / Claude Codeのインストール先
  ・パッケージ確認、インストール先準備、コピー、結果確認の4段階
  ・現在処理中のSkill
  ・進捗率とプログレスバー
  ・バックアップ先
  ・ログファイルの保存先


■ インストールされるSkill

  ・bulidics-api
    BULIDICS HTTP PushおよびREST APIの実装・確認に使用します。

  ・bulidics-water-leak-monitor
    漏水センサーの状態判定、状態遷移、履歴処理に使用します。


■ 呼び出し例

  Codex:
    $bulidics-api BULIDICSのPush API受信処理を確認してください
    $bulidics-water-leak-monitor 漏水状態の履歴処理を確認してください

  Cursor / Claude Code:
    /bulidics-api BULIDICSのPush API受信処理を確認してください
    /bulidics-water-leak-monitor 漏水状態の履歴処理を確認してください

自然な文章で依頼した場合も、内容に応じてSkillが自動選択されます。


■ インストール先

  Codex / Cursor:
    %USERPROFILE%\.agents\skills

  Claude Code:
    %USERPROFILE%\.claude\skills


■ 更新方法

  新しいインストールキットのinstall.cmdを再度実行してください。
  既存Skillは自動的にバックアップしてから更新されます。


■ アンインストール

  uninstall.cmdをダブルクリックしてください。
  BULIDICSの2つのSkillだけが削除されます。
  削除前にバックアップが作成されます。


■ 手動インストール

PowerShellの実行が会社のセキュリティポリシーで禁止されている場合は、
skillsフォルダー内の2つのフォルダーを、次の場所へ手動でコピーしてください。

  Codex / Cursor:
    %USERPROFILE%\.agents\skills

  Claude Code:
    %USERPROFILE%\.claude\skills


■ セキュリティ

このインストールキットには、API Key、BULIDICS認証情報、Dify MCP URL、
顧客システムの認証情報は含まれていません。

認証情報は各利用者のローカル設定または安全な秘密管理機能で設定してください。
