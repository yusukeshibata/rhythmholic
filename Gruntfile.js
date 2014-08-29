module.exports = function(grunt) {

  var pkg = grunt.file.readJSON('package.json');

  grunt.initConfig({
    //compc : {
    //  build : {
    //    src: ['src/swc/tmp/org/flashsandy/display/DistortImage.as'],
    //    dest: 'src/swc/distortimage.swc',
    //    //options : {
    //    //  'external-library-path+=src/swc/as3corelib.swc' : undefined,
    //    //  'external-library-path+=src/swc/ktween.swc' : undefined,
    //    //}
    //  }
    //},
    mxmlc : {
      options : {
        rawConfig : "-managers flash.fonts.AFEFontManager",
      },
      profile : {
        files : { 'bin/backscreen.swf' : ['src/Backscreen.as'] }
      }
    },
    watch: {
      files: ['src/*.as'],
      tasks: ['mxmlc']
    }
  });
  var taskName;
  for(taskName in pkg.devDependencies) {
    if(taskName.substring(0, 6) == 'grunt-') {
      grunt.loadNpmTasks(taskName);
    }
  }
  grunt.registerTask('default', ['mxmlc','watch']);
};

