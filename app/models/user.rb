class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :last_name,               presence: true, length: { maximum: 255 }
  validates :first_name,              presence: true, length: { maximum: 255 }
  validates :email,                   presence: true, uniqueness: true
  validates :password,                presence: true, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password,                confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation,   presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true

  has_many :boards, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarks_boards, through: :bookmarks, source: :board

  mount_uploader :avatar, AvatarUploader

  enum role: { general: 0, admin: 1 }

  def bookmark(board)
    bookmarks_boards << board
  end

  def unbookmark(board)
    bookmarks_boards.destroy(board)
  end

  def bookmark?(board)
    bookmarks_boards.include?(board)
  end

  def own?(object)
    id == object&.user_id
  end
end
