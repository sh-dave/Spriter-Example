var project = new Project('SpriterExample-Kha-g2');

project.addSources('src/spriter/example-kha-g2');
project.addSources('SpriterHaxeEngine');

project.addAssets('assets/player1/**');

// project.addAssets('assets/ugly/ugly.scml');
// project.addAssets('assets/ugly/ugly.png');
// project.addAssets('assets/ugly/ugly.xml');

return project;
