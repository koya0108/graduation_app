class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |user|
      if user.pending_employee_code.present?
        user.update(employee_code: user.pending_employee_code, pending_employee_code: nil)
      end
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    flash[:notice] = "ユーザー情報が更新されました。"
    projects_path # 認証後のリダイレクト先
  end
end
