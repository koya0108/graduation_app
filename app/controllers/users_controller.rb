class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # 入力値から空欄を除外して取得
    user_attrs = user_params.compact_blank

    # 現在の値と比較して変更があったか判定
    changes = user_attrs.select { |key, value| @user[key] != value && value.present? }

    if changes.empty?
      flash.now[:alert] = "変更内容がありません"
      render :edit, status: :unprocessable_entity
      return
    end

    # email重複チェック
    if changes.key?("email") && User.where(email: changes["email"]).exists?
      flash.now[:alert] = "このメールアドレスは既に使用されています"
      render :edit, status: :unprocessable_entity
      return
    end

    # ログインID重複チェック
    if changes.key?("employee_code") && User.where(employee_code: changes["employee_code"]).exists?
      flash.now[:alert] = "このログインIDは既に使用されています"
      render :edit, status: :unprocessable_entity
      return
    end

    @user.assign_attributes(changes.except("employee_code"))
    @user.pending_employee_code = changes["employee_code"] if changes.key?("employee_code")

    # バリデーションチェックを先に実行
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
      return
    end

    if changes.key?("email") || changes.key?("employee_code")
      # 確認メール送信
      @user.send_confirmation_instructions
      redirect_to edit_user_path, notice: "確認メールを送信しました。メール内のリンクをクリックして変更を確定してください。"
    else
      if @user.update(changes)
        redirect_to edit_user_path, notice: "アカウント情報を更新しました。"
      else
        flash.now[:alert] = "更新に失敗しました。"
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:employee_code, :email)
  end
end
