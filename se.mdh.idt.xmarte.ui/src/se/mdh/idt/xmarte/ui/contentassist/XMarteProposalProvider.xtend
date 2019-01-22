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

	val xComponentConstraints = #{
		[String keyword, XComponent xComponent | keyword == 'kind'  && !xComponent.isAllocated],
		[String keyword, XComponent xComponent | keyword == 'level' && !xComponent.isHwCache],
		[String keyword, XComponent xComponent | keyword == 'cores' && !xComponent.isHwProcessor]
	}

	override completeKeyword(Keyword keyword, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		context.currentModel.completeKeyword(keyword, context, acceptor)
	}
	
	def dispatch void completeKeyword(
		XComponent xComponent, 
		Keyword keyword, 
		ContentAssistContext context, 
		ICompletionProposalAcceptor acceptor
	) {
		if (!xComponentConstraints.exists[apply(keyword.value, xComponent)]) {
			super.completeKeyword(keyword, context, acceptor)
		}
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
