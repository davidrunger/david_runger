module MemoWisePatches
  def prepended(target)
    super

    target.singleton_class.alias_method(:memoize, :memo_wise)
  end
end

MemoWise.singleton_class.prepend(MemoWisePatches)

Memoization = MemoWise
