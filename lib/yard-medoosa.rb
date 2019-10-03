require "yard/medoosa"

module YARD
  module CLI
    # Monkey patch YARD to hook into `yard doc`
    class Yardoc
      include Medoosa

      def run_generate_with_medoosa(*args)
        run_generate_without_medoosa(*args)
        fname = generate_medoosa(options.serializer.basepath)
        options.files << CodeObjects::ExtraFileObject.new(fname)
        # FIXME: what, do we really run it twice?!
        # yes, until I figure out a better place to hook generate_medoosa in
        run_generate_without_medoosa(*args)
      end

      alias run_generate_without_medoosa run_generate
      alias run_generate run_generate_with_medoosa
    end
  end
end
