/*
 * generated by Xtext 2.10.0
 */
package se.mdh.idt.xmarte.tests

import com.google.inject.Inject
import org.eclipse.uml2.uml.Model
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.junit.Assert.assertNotNull

@RunWith(XtextRunner)
@InjectWith(XMarteInjectorProvider)
class XMarteParsingTest {

	@Inject extension ParseHelper<Model>
	
	@Test def void loadModel() {
		'''
			model aModel {
				
				allocated
				processor
				component aProcessor {
					
					kind = executionPlatform
					cores = 1
					
					allocated
					cache
					component aCache {
						kind = application
						level = 1
					}
					
					cache
					allocated
					component anotherCache {
						level = 2
						kind = executionPlatform
					} 
				}
				
				allocated processor anotherProcessor {
					cores = 10
				}
				
			}
		'''.parse => [assertNotNull]
	}

}
