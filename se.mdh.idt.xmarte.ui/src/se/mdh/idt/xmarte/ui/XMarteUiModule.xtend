/*
 * generated by Xtext 2.10.0
 */
package se.mdh.idt.xmarte.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ui.editor.model.XtextDocumentProvider
import se.mdh.idt.xmarte.ui.editor.model.XMarteDocumentProvider

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class XMarteUiModule extends AbstractXMarteUiModule {

	def Class<? extends XtextDocumentProvider> bindXtextDocumentProvider() {
		XMarteDocumentProvider
	}

}