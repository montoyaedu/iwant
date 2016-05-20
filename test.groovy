/**
 * Created by IntelliJ IDEA.
 * User: Kumappus
 * Date: 11/08/13
 * Time: 0:02
 * To change this template use File | Settings | File Templates.
 */

import groovy.swing.SwingBuilder
import javax.swing.JFrame
import groovy.swing.factory.SwingBorderFactory

sb = new SwingBuilder()

def dialog(event){
    dialog = sb.dialog(title: 'Entry')
    def panel = sb.panel{
        vbox {
            hbox{
               label(text: 'Name    ')
               textField(columns: 20, id: 'name')
            }
            hbox{
               label(text: 'Password ')
               passwordField(columns: 20, id: 'password')
            }
             hbox{
                button('OK') // add actionPerformed:
                button('Cancel')
            }
        }
    }
    dialog.getContentPane().add(panel)
    dialog.pack()
    dialog.show()
}


new SwingBuilder().frame( title: "TEST",defaultCloseOperation: JFrame.EXIT_ON_CLOSE, pack: true, show: true ){
    panel{
        button(actionPerformed: this.&dialog, "Click")
    }
}
