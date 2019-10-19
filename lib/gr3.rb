# frozen_string_literal: true

require 'ffi'

module GR3
  class Error < StandardError; end

  class << self
    attr_reader :ffi_lib
  end

  # Platforms |  path
  # Windows   |  bin/libgr3.dll
  # MacOSX    |  lib/libGR3.so (NOT .dylib)
  # Ubuntu    |  lib/libGR3.so
  raise 'Please set env variable GRDIR' unless ENV['GRDIR']

  ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
  @ffi_lib = case RbConfig::CONFIG['host_os']
             when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
               File.expand_path('bin/libgr3.dll', ENV['GRDIR'])
                   .gsub('/', '\\') # windows backslash
             else
               File.expand_path('lib/libGR3.so', ENV['GRDIR'])
             end

  require_relative 'gr_commons'
  require_relative 'gr3/ffi'
  require_relative 'gr3/gr3base'

  extend GRCommons::JupyterSupport
  extend GR3Base

  # 1. double is the default type
  # 2. don't check size (for now)

  module CheckError
    FFI.ffi_methods.each do |method|
      method_name = method.to_s.sub(/^gr3_/, '')
      next if method_name == 'geterror'

      define_method(method_name) do |*args|
        values = super(*args)
        GR3Base.check_error
        values
      end
    end
  end
  extend CheckError

  class << self
    def createmesh_nocopy(_n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, vertices, normals, colors)
      end
    end

    def createmesh(_n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, vertices, normals, colors)
      end
    end

    def createindexedmesh_nocopy(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    def createindexedmesh(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    def getimage(width, height, use_alpha = true)
      bpp = use_alpha ? 4 : 3
      inquiry(uint8: width * height * bpp) do |bitmap|
        super(width, height, (use_alpha ? 1 : 0), bitmap)
      end
    end

    # gr3_gr

    def createsurfacemesh(nx, ny, px, py, pz, option = 0)
      inquiry_int do |mesh|
        super(mesh, nx, ny, px, py, pz, option)
      end
    end

    # gr3_convenience

    def drawtubemesh(n, points, colors, radii, num_steps = 10, num_segments = 20)
      super(n, points, colors, radii, num_steps, num_segments)
    end
  end

  IA_END_OF_LIST = 0
  IA_FRAMEBUFFER_WIDTH = 1
  IA_FRAMEBUFFER_HEIGHT = 2

  ERROR_NONE = 0
  ERROR_INVALID_VALUE = 1
  ERROR_INVALID_ATTRIBUTE = 2
  ERROR_INIT_FAILED = 3
  ERROR_OPENGL_ERR = 4
  ERROR_OUT_OF_MEM = 5
  ERROR_NOT_INITIALIZED = 6
  ERROR_CAMERA_NOT_INITIALIZED = 7
  ERROR_UNKNOWN_FILE_EXTENSION = 8
  ERROR_CANNOT_OPEN_FILE = 9
  ERROR_EXPORT = 10

  QUALITY_OPENGL_NO_SSAA  = 0
  QUALITY_OPENGL_2X_SSAA  = 2
  QUALITY_OPENGL_4X_SSAA  = 4
  QUALITY_OPENGL_8X_SSAA  = 8
  QUALITY_OPENGL_16X_SSAA = 16
  QUALITY_POVRAY_NO_SSAA  = 0 + 1
  QUALITY_POVRAY_2X_SSAA  = 2 + 1
  QUALITY_POVRAY_4X_SSAA  = 4 + 1
  QUALITY_POVRAY_8X_SSAA  = 8 + 1
  QUALITY_POVRAY_16X_SSAA = 16 + 1

  DRAWABLE_OPENGL = 1
  DRAWABLE_GKS = 2

  SURFACE_DEFAULT     =  0
  SURFACE_NORMALS     =  1
  SURFACE_FLAT        =  2
  SURFACE_GRTRANSFORM =  4
  SURFACE_GRCOLOR     =  8
  SURFACE_GRZSHADED   = 16
end
