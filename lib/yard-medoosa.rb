require "yard/medoosa"

module YARD
  module CLI
    # Monkey patch YARD to hook into `yard doc`
    class Yardoc
      include Medoosa

      def run_generate_with_medoosa(*args)
        run_generate_without_medoosa(*args)
        generate_medoosa(options.serializer.basepath)
      end

      alias run_generate_without_medoosa run_generate
      alias run_generate run_generate_with_medoosa
    end
  end
end
