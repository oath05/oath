import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var store: AccountStore
    @Environment(\.dismiss) private var dismiss

    @State private var label = ""
    @State private var email = ""
    @FocusState private var focus: Field?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private enum Field { case label, email }

    private var canSave: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0x0E0F12).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        field(title: "备注名",
                              placeholder: "例如：主号 / 美区 / 小号",
                              text: $label,
                              keyboard: .default)
                            .focused($focus, equals: .label)

                        field(title: "Apple ID",
                              placeholder: "name@example.com 或手机号",
                              text: $email,
                              keyboard: .emailAddress)
                            .focused($focus, equals: .email)

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x00D98B))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("不保存密码")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(hex: 0xD5D8DE))
                                Text("本条记录只保存备注和邮箱，保存在本机。密码请在系统登录页输入，App 不会读取也不会存档。")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: 0x8A8F99))
                                    .lineSpacing(3)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: 0x16181D), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 0.8))

                        Button(action: save) {
                            Text("保存账号")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(canSave ? Color(hex: 0x0B0C0F) : Color(hex: 0x6B6F78))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(canSave ? Color(hex: 0x00E08F) : Color(hex: 0x1E2128),
                                            in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("添加账号")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }.foregroundStyle(Color(hex: 0x8A8F99))
                }
            }
            .onAppear { focus = .label }
        }
    }

    private func field(title: String,
                       placeholder: String,
                       text: Binding<String>,
                       keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x8A8F99))
                .padding(.leading, 4)

            TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color(hex: 0x5C6069)))
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(hex: 0x16181D), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 0.8))
        }
    }

    private func save() {
        store.add(label: label, email: email)
        dismiss()
    }
}
