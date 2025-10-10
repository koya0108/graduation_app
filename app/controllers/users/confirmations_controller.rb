class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    # email変更ではなく、employee_codeのみの変更だった場合はconfirmエラーを無視する
    if resource.unconfirmed_email.blank? && resource.pending_employee_code.present? && resource.errors.present?
       resource.errors.clear
    end

    if resource.errors.empty?
      if resource.pending_employee_code.present?
        resource.update(employee_code: resource.pending_employee_code, pending_employee_code: nil)
      end

      set_flash_message!(:notice, :confirmed)
      sign_in(resource_name, resource) unless user_signed_in?
      redirect_to edit_user_path, notice: "ユーザー情報が更新されました"
    else
      flash[:alert] = "確認リンクが無効または期限切れです。再度メールを送信してください。"
      redirect_to edit_user_path
    end
  end
end
