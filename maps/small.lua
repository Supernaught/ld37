return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.17.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 5,
  height = 5,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "tiles.png",
      imagewidth = 64,
      imageheight = 64,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 16,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "solid",
      x = 0,
      y = 0,
      width = 5,
      height = 5,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        1, 1, 1, 1, 1
      }
    }
  }
}
