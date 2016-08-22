module DoubleDutch
  module SpaceCadet
    class Error < StandardError; end
    class ServerNotFound < DoubleDutch::SpaceCadet::Error; end
    class LBNotFound < DoubleDutch::SpaceCadet::Error; end
    class LBInconsistentState < DoubleDutch::SpaceCadet::Error; end
    class LBUnsafe < DoubleDutch::SpaceCadet::Error; end
    class MalformedNodeObject < DoubleDutch::SpaceCadet::Error; end
  end
end
