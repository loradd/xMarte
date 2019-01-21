package se.mdh.idt.xmarte.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import se.mdh.idt.xmarte.xMarte.XComponent

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class XMarteProposalProvider extends AbstractXMarteProposalProvider {

	override completeKeyword(Keyword keyword, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		context.currentModel.completeKeyword(keyword, context, acceptor)
	}

	def dispatch void completeKeyword(
		XComponent xComponent,
		Keyword keyword,
		ContentAssistContext context,
		ICompletionProposalAcceptor acceptor
	) {
		if('kind'.equals(keyword.value) && !xComponent.isAllocated) return;
		if('level'.equals(keyword.value) && !xComponent.isHwCache) return;
		if('cores'.equals(keyword.value) && !xComponent.isHwProcessor) return;
		if('cache'.equals(keyword.value) && !xComponent.isHwProcessor) return;
		super.completeKeyword(keyword, context, acceptor)
	}

	def dispatch void completeKeyword(
		EObject eObject,
		Keyword keyword,
		ContentAssistContext context,
		ICompletionProposalAcceptor acceptor
	) {
		super.completeKeyword(keyword, context, acceptor)
	}

}
