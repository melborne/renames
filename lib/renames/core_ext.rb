module CoreExtention
  refine(Array) do
    def same?(&blk)
      uniq(&blk).size==1
    end
  end
end