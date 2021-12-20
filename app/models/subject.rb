class Subject < ApplicationRecord
  # ランダムに Subject インスタンスを取得して返す
  def self.choose_one
    find( pluck(:id).sample )
  end
end
