// supabase/functions/send-email/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { Resend } from 'npm:resend'
import { Brevo } from 'npm:@sendinblue/client'

const resend = new Resend(Deno.env.get('RESEND_API_KEY'))
const brevo = new Brevo({ apiKey: Deno.env.get('BREVO_API_KEY') })

serve(async (req) => {
  const { type, to, provider } = await req.json()
  
  try {
    if (provider === 'resend') {
      await resend.emails.send({
        from: 'noreply@yourdomain.com',
        to,
        subject: getSubject(type),
        html: getEmailTemplate(type),
      })
    } else if (provider === 'brevo') {
      await brevo.sendTransacEmail({
        to: [{ email: to }],
        templateId: getTemplateId(type),
        params: getTemplateParams(type),
      })
    }
    
    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
