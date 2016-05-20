var fs = require('fs');
var input = process.env['IWANT_HOME'] + '/context.js';
var output = process.env['IWANT_HOME'] + '/.context.js';
var file = require(input);

for(var propertyName in file) {
    file[propertyName] = process.env[propertyName];
    console.log(propertyName + ' = [' + file[propertyName] + ']');
}

fs.writeFile(output, 'module.exports = ' + JSON.stringify(file, null, 4), function (err) {
    if (err) {
        return console.log(err);
    }
    console.log('writing to ' + output);
});
